let Concourse = ../deps/concourse.dhall

let GKECreds = ../types/gke-creds.dhall

let IKSCreds = ../types/iks-creds.dhall

let Requirements =
      { creds : ../types/creds.dhall
      , ciResources : Concourse.Types.Resource
      , upstreamEvent : Concourse.Types.Resource
      , clusterName : Text
      , grafanaAdminPassword : Text
      }

in    λ(reqs : Requirements)
    → let ingressEndpointTask =
            merge
              { GKECreds =
                    λ(_ : GKECreds)
                  → ../tasks/get-gke-ingress-endpoint.dhall reqs.clusterName
              , IKSCreds =
                    λ(iksCreds : IKSCreds)
                  → ../tasks/get-iks-ingress-endpoint.dhall
                      reqs.ciResources
                      reqs.clusterName
                      iksCreds
              }
              reqs.creds

      let grafanaSecretSetupTask =
            merge
              { GKECreds =
                  λ(_ : GKECreds) → ../tasks/set-up-gke-grafana-secret.dhall
              , IKSCreds =
                    λ(iksCreds : IKSCreds)
                  → ../tasks/set-up-iks-grafana-secret.dhall
                      reqs.clusterName
                      iksCreds
                      reqs.ciResources
              }
              reqs.creds

      let providerValuesFile =
            merge
              { GKECreds = λ(_ : GKECreds) → "gke-specific-grafana-values.yml"
              , IKSCreds = λ(_ : IKSCreds) → "iks-specific-grafana-values.yml"
              }
              reqs.creds

      let script =
            ''
            set -euo pipefail
            ${../tasks/functions/install-monitoring.sh as Text}

            install_monitoring \
              "${reqs.ciResources.name}" \
              "${reqs.grafanaAdminPassword}" \
              "${providerValuesFile}"
            ''

      let installTask =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "install-monitoring"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall "eirini/ibmcloud"
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{
                            , name = reqs.ciResources.name
                            }
                          , Concourse.schemas.TaskInput::{ name = "kube" }
                          , Concourse.schemas.TaskInput::{ name = "ingress" }
                          , Concourse.schemas.TaskInput::{ name = "secret" }
                          ]
                    , run =
                        Concourse.schemas.TaskRunConfig::{
                        , path = "bash"
                        , args = Some [ "-c", script ]
                        }
                    }
              }

      let downloadKubeConfig =
            ../tasks/download-kubeconfig.dhall
              reqs.ciResources
              reqs.clusterName
              reqs.creds

      let triggerOnClusterReady =
            Concourse.helpers.getStep
              Concourse.schemas.GetStep::{
              , resource = reqs.upstreamEvent
              , trigger = Some True
              , passed = Some [ "prepare-cluster-${reqs.clusterName}" ]
              }

      in  Concourse.schemas.Job::{
          , name = "install-monitoring-${reqs.clusterName}"
          , plan =
              [ ../helpers/get.dhall reqs.ciResources
              , triggerOnClusterReady
              , downloadKubeConfig
              , ingressEndpointTask
              , grafanaSecretSetupTask
              , installTask
              ]
          }
