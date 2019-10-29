let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let eirini
    : Text → Concourse.Types.Resource
    =   λ(branch : Text)
      →   Concourse.defaults.Resource
        ⫽ { name = "eirini"
          , type = Concourse.Types.ResourceType.InBuilt "git"
          , icon = Some "git"
          , source =
              Some
                ( toMap
                    { uri =
                        Prelude.JSON.string
                          "https://github.com/cloudfoundry-incubator/eirini.git"
                    , branch = Prelude.JSON.string branch
                    , ignore_paths =
                        Prelude.JSON.array
                          [ Prelude.JSON.string "docker/opi/init/"
                          , Prelude.JSON.string
                              "docker/registry/certs/smuggler/"
                          , Prelude.JSON.string "fluentd/"
                          ]
                    }
                )
          }

in  eirini
