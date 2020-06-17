let Concourse = ../deps/concourse.dhall

let do = Concourse.helpers.doStep

let in_parallel = Concourse.helpers.inParallelStepSimple

let taskFile = ../helpers/task-file.dhall

let RunTestRequirements = ../types/run-test-requirements.dhall

let triggerOnGolangLint = ../helpers/trigger-on-golang-lint.dhall

let get = ../helpers/get.dhall

let getTrigger = ../helpers/get-trigger.dhall

let getTriggerPassed = ../helpers/get-trigger-passed.dhall

let runTestsJob =
        λ(reqs : RunTestRequirements)
      → let getClusterReady =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = reqs.upstream.event
                , trigger = Some reqs.enableNonCodeAutoTriggers
                , passed = Some [ "${reqs.upstream.name}-${reqs.clusterName}" ]
                }

        let triggerOnEirini =
              Optional/fold
                (List Text)
                reqs.eiriniUpstreams
                Concourse.Types.Step
                (getTriggerPassed reqs.eiriniRepo)
                (getTrigger reqs.eiriniRepo)

        let getSampleConfigs =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = reqs.sampleConfigs
                , trigger = Some reqs.enableNonCodeAutoTriggers
                }

        let getEiriniRelease =
              Concourse.helpers.getStep
                Concourse.schemas.GetStep::{
                , resource = reqs.eiriniReleaseRepo
                , trigger = Some reqs.enableNonCodeAutoTriggers
                }

        let runUnitTests =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "run-unit-tests"
                , config = taskFile reqs.ciResources "run-unit-tests"
                }

        let runStaticChecks =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "run-static-checks"
                , config = taskFile reqs.ciResources "run-static-checks"
                }

        let downloadKubeconfig =
              ../tasks/download-kubeconfig.dhall
                reqs.ciResources
                reqs.clusterName
                reqs.creds

        let applyLrpCrd =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "apply-lrp-crd"
                , config = taskFile reqs.ciResources "apply-lrp-crd"
                }

        let runIntegrationTests =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "run-integration-tests"
                , config = taskFile reqs.ciResources "run-integration-tests"
                }

        let deleteLrpCrd =
              Concourse.helpers.taskStep
                Concourse.schemas.TaskStep::{
                , task = "delete-lrp-crd"
                , config = taskFile reqs.ciResources "delete-lrp-crd"
                }

        in    Concourse.defaults.Job
            ⫽ { name = "run-tests"
              , public = Some True
              , plan =
                [ in_parallel
                    [ getClusterReady
                    , triggerOnEirini
                    , getSampleConfigs
                    , getEiriniRelease
                    , triggerOnGolangLint
                    , get reqs.ciResources
                    ]
                , in_parallel
                    [ runUnitTests
                    , runStaticChecks
                    , do
                        [ downloadKubeconfig
                        , applyLrpCrd
                        , runIntegrationTests
                        , deleteLrpCrd
                        ]
                    ]
                ]
              }

in  runTestsJob
