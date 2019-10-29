let Concourse = ../deps/concourse.dhall

let IKSCreds = ./iks-creds.dhall

let ImageLocation = ./image-location.dhall

in  { clusterName : Text
    , worldName : Text
    , uaaResources : Concourse.Types.Resource
    , ciResources : Concourse.Types.Resource
    , eiriniReleaseRepo : Concourse.Types.Resource
    , clusterReadyEvent : Concourse.Types.Resource
    , uaaReadyEvent : Concourse.Types.Resource
    , clusterState : Concourse.Types.Resource
    , smokeTestsResource : Concourse.Types.Resource
    , downloadKubeconfigTask : Concourse.Types.Step
    , useCertManager : Text
    , iksCreds : IKSCreds
    , imageLocation : ImageLocation
    , skippedCats : Optional Text
    }
