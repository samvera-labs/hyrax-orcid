namespace :hyrax do
  namespace :orcid do
    namespace :install do
      desc "Copy migrations from Hyrax Orcid to application"
      task migrations: :environment do
        Hyrax::Orcid::DatabaseMigrator.copy
      end
    end
  end
end
