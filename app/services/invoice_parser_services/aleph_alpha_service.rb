# frozen_string_literal: true

module InvoiceParserServices
  class AlephAlphaService < ApplicationService
    dependency :aleph_alpha_client

    # Return { company: 'Orange', amount: 26.99, currency: 'EUR', date: '08/12/2022' }
    def call(text:)
      response = aleph_alpha_client.complete(build_prompt(text))
      completion = response[:completions].first
      # TODO: track the error
      completion[:reason] == 'end_of_text' ? JSON.parse(output) : nil
    end

    private

    def build_prompt(text)
      <<~PROMPT
        ### Instruction:
        The input is about an invoice sent to me by email. The input represents the body of the email.#{' '}
        Please extract the company name which sent me the email, the total amount, the currency and the date of the invoice as json.
        ### Input:
        #{input}
        ### Response:
        { "company": "Apple", "total_amount": 0.99, "currency": "EUR", "date": "04/08/2023" }
        ### Input:
        #{text}
        ### Response:
      PROMPT
    end

    def input
      <<~TEXT
        From: Apple <no_reply@email.apple.com>
        Subject: Votre facture Apple
        Date: August 3, 2023 at 4:07:52 PM GMT+2
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
        4 août 2023 N° DE SÉQUENCE
        1-7869074822
        N° DE COMMANDE
        MN3ZVZFTM6 <https://support.apple.com/kb/HT204088?cid=email_receipt_itunes_article_HT204088>  N° DE DOCUMENT
        139692210181
        iCloud+
          iCloud+ avec 50 Go de stockage
        Mensuel
        Renouv. le 4 sept. 2023
        0,99 €
        TVA à 20 % comprise   0,16 €
        Sous-total    0,83 €

        TVA facturée à 20 %   0,16 €
        TOTAL   0,99 €

        Si vous avez des questions concernant votre facture, contactez l’assistance <https://support.apple.com/fr-fr/billing?cid=email_receipt>. Cet e‑mail confirme le paiement du forfait iCloud+ indiqué ci‑dessus. Votre forfait sera facturé à chaque cycle d’abonnement à moins de le résilier en revenant <https://support.apple.com/kb/HT207594> au forfait de stockage gratuit sur votre appareil iOS, Mac ou PC.

        Vous pouvez contacter Apple pour bénéficier d’un remboursement dans un délai de 15 jours après la mise à jour d’un abonnement mensuel, ou dans un délai de 45 jours après un paiement annuel. Des remboursements partiels sont disponibles en cas d’obligation légale.

        Vous avez la possibilité d’arrêter de recevoir par e-mail les reçus correspondant au renouvellement de vos abonnements. Si tel est le cas, sachez que vous pouvez toujours les consulter dans l’historique des achats de votre compte. Pour consulter vos reçus ou choisir de les recevoir à nouveau, accédez à Réglages du compte <https://finance-app.itunes.apple.com/account/subscriptions?unsupportedRedirectUrl=https://apps.apple.com/FR/invoice>.




        Détails du compte <https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/accountSummary?mt=8> • Historique d’achats <https://finance-app.itunes.apple.com/purchases> • Conditions générales de vente <http://www.apple.com/legal/internet-services/icloud/ww/> • Engagement de confidentialité <https://www.apple.com/fr/privacy/>

        Copyright © 2023 Apple Distribution International Ltd.
        Tous droits réservés <https://www.apple.com/fr/legal/>
        Hollyhill Industrial Estate, Hollyhill, Cork, Irlande. N° de TVA pour l'Irlande : IE9700053D
      TEXT
    end
  end
end