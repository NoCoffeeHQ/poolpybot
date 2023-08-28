# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceParserServices::OpenaiService do
  let(:container) { ApplicationContainer.new }
  let(:client) { container.openai_client }
  let(:instance) { described_class.new(openai_client: client) }

  subject { instance.call(text: text, company_name: 'NoCoffee') }

  describe 'Given the invoice is from an Apple email' do
    let(:text) do
      <<~EMAIL
        Begin forwarded message:

        From: Apple <no_reply@email.apple.com>
        Subject: Votre facture Apple
        Date: June 26, 2023 at 2:05:25 PM GMT+2
        To: didier.lafforgue@icloud.com



          Facture

        IDENTIFIANT APPLE
        didier.lafforgue@icloud.com <mailto:didier.lafforgue@icloud.com>  FACTURÉ À
        Amex .... 1006
        Estelle Lafforgue
        7 allee Albert Camus
        31700 France
        FRA
        DATE DE LA FACTURE
        26 juin 2023  N° DE SÉQUENCE
        1-7702428465
        N° DE COMMANDE
        MN3ZTKZ59B <https://support.apple.com/kb/HT204088?cid=email_receipt_itunes_article_HT204088>  N° DE DOCUMENT
        194677656541
        App Store
          Le Monde, Actualités en direct
        Offre Essentiel (Mensuel)
        Renouv. le 26 juil. 2023
        Signaler un problème <https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/reportAProblem?a=1500013498&cc=fr&d=111115745&o=i&p=64064185827905&pli=64092234487902&s=1>
        12,99 €
        TVA à 2,1 % comprise    0,27 €
        Sous-total    12,72 €

        TVA facturée à 2,1 %    0,27 €
        TOTAL   12,99 €

        Confidentialité : nous utilisons un identifiant d’abonné <http://support.apple.com/kb/HT207233> pour fournir des rapports aux développeurs.

        Obtenez de l’aide pour les abonnements et les achats. Consultez l’assistance Apple <https://support.apple.com/fr-fr/billing?cid=email_receipt>.

        Découvrez comment gérer les préférences applicables au mot de passe <https://support.apple.com/kb/HT204030?cid=email_receipt_itunes_article_HT204030> pour les achats dans iTunes, Apple Books et l’App Store.

        Pour annuler votre achat dans les 14 jours suivant la réception de cette facture, signalez un problème <https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/reportAProblem?a=1500013498&cc=fr&d=111115745&o=i&p=64064185827905&pli=64092234487902&s=1> ou contactez-nous <http://www.apple.com/fr/support/itunes/contact/>.
        En savoir plus sur votre droit de rétractation <http://www.apple.com/legal/internet-services/itunes/fr/rightofwithdrawal-fr.pdf>


        Vous avez la possibilité d’arrêter de recevoir par e-mail les reçus correspondant au renouvellement de vos abonnements. Si tel est le cas, sachez que vous pouvez toujours les consulter dans l’historique des achats de votre compte. Pour consulter vos reçus ou choisir de les recevoir à nouveau, accédez à Réglages du compte <https://finance-app.itunes.apple.com/account/subscriptions?unsupportedRedirectUrl=https://apps.apple.com/FR/invoice>.




        Détails du compte <https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/accountSummary?mt=8> • Conditions générales de vente <https://www.apple.com/legal/internet-services/itunes/fr/terms.html#SALE> • Engagement de confidentialité <https://www.apple.com/fr/privacy/>

        Copyright © 2023 Apple Distribution International Ltd.
        Tous droits réservés <https://www.apple.com/fr/legal/>
        Hollyhill Industrial Estate, Hollyhill, Cork, Irlande. N° de TVA pour l'Irlande : IE9700053D
      EMAIL
    end

    it 'extracts the correct information' do
      skip 'No need to spend money on that test' if ENV['RSPEC_DISABLE_OPENAI_CALLS'] == '1'
      is_expected.to eq({
        company_name: 'Apple',
        identifier: '1-7702428465',
        date: '2023/06/26',
        total_amount: 12.99,
        tax_rate: 2.1,
        currency: 'EUR'
      }.with_indifferent_access)
    end
  end

  describe 'Given the invoice is from an Heroku invoice' do
    let(:text) do
      <<~EMAIL
                Hello,

        Your Heroku invoice for July 2023 is now available. We will charge your credit card $50.17 within the next two business days.

        You can review all charges for your account (nocoffee) on your invoice.

        For a detailed breakdown, log into your Heroku account and visit: https://dashboard.heroku.com/orgs/nocoffee/invoices/2023/07

        Need support? Submit a ticket at https://help.heroku.com/

        Thanks for choosing Heroku,
        The Heroku Billing Team


        Account:
        nocoffee

        Billed to:
        Estelle Lafforgue
        7 allée Albert Camus
        Blagnac Haute-Garonne, 31700
        FR
        NoCoffee SARL

        Billing period:
        July 01, 2023 - August 01, 2023

        Invoice #:
        84913487


        Charges
        Amount
        Application dynos $ 50.11
        Add-on services $ 0.06
        Subtotal: $ 50.17
        Total:

        $ 50.17
      EMAIL
    end

    it 'extracts the correct information' do
      skip 'No need to spend money on that test' if ENV['RSPEC_DISABLE_OPENAI_CALLS'] == '1'
      is_expected.to eq({
        company_name: 'Heroku',
        identifier: '84913487',
        date: '2023/07/01',
        total_amount: 50.17,
        tax_rate: nil,
        currency: 'USD'
      }.with_indifferent_access)
    end
  end

  describe 'Given Openai hallucinated and doesn\'t return the expected JSON structure' do
    let(:response) { { choices: [{ message: { content: '{"company":"Apple"}' } }] } }
    let(:client) { instance_double('OpenaiClient', complete: response) }
    let(:text) { 'Lorem ipsum...' }

    it 'returns false' do
      is_expected.to eq false
    end
  end
end
