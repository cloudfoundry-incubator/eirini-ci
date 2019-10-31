let Concourse = ../deps/concourse.dhall

in  { writeableEiriniReleaseRepo : Concourse.Types.Resource
    , ciResources : Concourse.Types.Resource
    , eiriniRepo : Concourse.Types.Resource
    , fluentdRepo : Concourse.Types.Resource
    , secretSmugglerRepo : Concourse.Types.Resource
    , dockerOPI : Concourse.Types.Resource
    , dockerRootfsPatcher : Concourse.Types.Resource
    , dockerBitsWaiter : Concourse.Types.Resource
    , eiriniStagingRepo : Concourse.Types.Resource
    , dockerDownloader : Concourse.Types.Resource
    , dockerExecutor : Concourse.Types.Resource
    , dockerUploader : Concourse.Types.Resource
    , dockerFluentd : Concourse.Types.Resource
    , dockerSecretSmuggler : Concourse.Types.Resource
    }
