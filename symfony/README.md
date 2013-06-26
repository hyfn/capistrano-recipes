A more complex PHP example, built around a Symfony app. It deploys the master branch to production and the develop branch to staging.

Multiple environments. Database credentials, logs and assets need to be uploaded manually to the "shared" directory on the server (which will be created after running `cap deploy:setup`) and will be symlinked into the release folder when deploying.

This allows them to live outside of version control and the release directories which are overwritten upon each deploy.