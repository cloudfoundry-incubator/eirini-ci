  λ(reqs : ./types/run-staging-test-requirements.dhall)
→ [ ./jobs/run-staging-tests.dhall reqs
  , ./jobs/create-staging-docker-images.dhall reqs
  ]