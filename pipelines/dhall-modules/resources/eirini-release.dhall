let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let eirini-release
    : Text → Concourse.Types.Resource
    =   λ ( branch
          : Text
          )
      →   Concourse.defaults.Resource
        ⫽ { name =
              "eirini-release"
          , type = Concourse.Types.ResourceType.InBuilt "git"
          , icon = Some "git"
          , source =
              Some
                ( toMap
                    { uri =
                        Prelude.JSON.string
                          "https://github.com/cloudfoundry-incubator/eirini-release.git"
                    , branch = Prelude.JSON.string branch
                    }
                )
          }

in  eirini-release
