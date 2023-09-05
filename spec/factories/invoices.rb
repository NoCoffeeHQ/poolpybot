# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  id                  :bigint           not null, primary key
#  currency            :string
#  date                :date
#  error               :integer          default("none")
#  status              :integer          default("created")
#  tax_rate            :float
#  total_amount        :float
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :bigint           not null
#  duplicate_of_id     :bigint
#  external_id         :string
#  invoice_supplier_id :bigint
#  user_id             :bigint           not null
#
# Indexes
#
#  index_invoices_on_company_id                  (company_id)
#  index_invoices_on_company_id_and_external_id  (company_id,external_id) UNIQUE
#  index_invoices_on_duplicate_of_id             (duplicate_of_id)
#  index_invoices_on_invoice_supplier_id         (invoice_supplier_id)
#  index_invoices_on_user_id                     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#  fk_rails_...  (duplicate_of_id => invoices.id)
#  fk_rails_...  (invoice_supplier_id => invoice_suppliers.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :invoice do
    company { nil }
    user { User.first || create(:user) }
    invoice_supplier { InvoiceSupplier.first || create(:invoice_supplier) }

    external_id { 'mail-provider-uuid@doe.net' }
    status { :created }

    date { nil }
    total_amount { nil }
    tax_rate { nil }
    currency { nil }

    trait :with_invoice_email do
      after(:build) do |invoice|
        create(:invoice_email, invoice: invoice)
      end
    end

    trait :with_tax_rate do
      total_amount { 0.99 }
      tax_rate { 20.0 }
    end

    trait :processed do
      status { :processed }
      date { Time.zone.today }
      total_amount { 42.0 }
    end

    trait :apple_pdf do
      external_id { 'apple-fake-uuid' }
      pdf_document { Rack::Test::UploadedFile.new('spec/fixtures/files/invoices/apple.pdf', 'application/pdf') }
    end

    trait :aws_pdf do
      external_id { 'aws-fake-uuid' }
      pdf_document { Rack::Test::UploadedFile.new('spec/fixtures/files/invoices/aws.pdf', 'application/pdf') }
    end

    trait :random_external_id do
      external_id { ('a'..'z').to_a.shuffle.join }
    end

    after(:build) do |invoice|
      invoice.company ||= invoice.user.company
      invoice.invoice_supplier ||= create(:invoice_supplier, company: invoice.company)
    end
  end
end
