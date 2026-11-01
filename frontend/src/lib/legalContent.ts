import type { Locale } from '@/i18n/translations';

type PrivacyBlock = {
  title: string;
  updated: string;
  sections: Array<{ heading: string; body: string | string[] }>;
  back: string;
};

type TermsBlock = PrivacyBlock;

const privacy: Record<Locale, PrivacyBlock> = {
  de: {
    title: 'Datenschutzerklärung',
    updated: 'Stand: 1. November 2026',
    back: '← Zurück zum Swiss Energy Assistant',
    sections: [
      {
        heading: '1. Überblick',
        body:
          'Swiss Energy Assistant («SEA», «die App») zeigt öffentlich verfügbare dynamische Strompreise schweizerischer Anbieter. Wir schützen Ihre Privatsphäre und erklären unsere Datenpraktiken transparent.',
      },
      {
        heading: '2. Daten, die wir NICHT erheben',
        body: [
          'Keine personenbezogenen Identifikationsdaten (Name, E-Mail, Telefon)',
          'Keine Registrierung oder Konto erforderlich',
          'Kein Standort- oder GPS-Tracking',
          'Keine Werbe-IDs',
          'Keine Drittanbieter-Analytics oder Tracking-SDKs',
          'Keine Weitergabe an Dritte',
        ],
      },
      {
        heading: '3. Lokal gespeicherte Daten',
        body:
          'Sprache, Postleitzahl, gewählter Anbieter, Geräteliste, Einstellungen und Benachrichtigungen werden ausschliesslich auf Ihrem Gerät (localStorage) gespeichert. Diese Daten verlassen Ihr Gerät nicht und können jederzeit durch Löschen der App-Daten entfernt werden.',
      },
      {
        heading: '4. Netzwerk',
        body:
          'Die App lädt Preisdaten von unserem Server (Proxy zu öffentlichen APIs von CKW, Groupe E und Primeo). Anfragen enthalten keine personenbezogenen Daten. Preise werden serverseitig 15 Minuten gecacht.',
      },
      {
        heading: '5. Benachrichtigungen',
        body: 'Push-Hinweise werden lokal auf dem Gerät erzeugt; kein Push-Server in der aktuellen Version.',
      },
      {
        heading: '6. Kontakt',
        body: 'Fragen zur Datenschutzerklärung: Kontakt über die App-Store-Einträge.',
      },
    ],
  },
  en: {
    title: 'Privacy Policy',
    updated: 'Last updated: 1 November 2026',
    back: '← Back to Swiss Energy Assistant',
    sections: [
      {
        heading: '1. Overview',
        body:
          'Swiss Energy Assistant ("SEA", "the App") displays publicly available dynamic electricity prices from Swiss energy providers. We are committed to protecting your privacy.',
      },
      {
        heading: '2. Data We Do NOT Collect',
        body: [
          'No personal identification data (name, email, phone)',
          'No registration or account required',
          'No location tracking or GPS data',
          'No advertising identifiers',
          'No third-party analytics or tracking SDKs',
          'No data shared with third parties',
        ],
      },
      {
        heading: '3. Data Stored Locally',
        body:
          'Language, postal code, selected provider, appliances, settings, and notification preferences are stored only on your device (local storage) and never leave it.',
      },
      {
        heading: '4. Network Requests',
        body:
          'The App fetches price data via our server proxy to public APIs from CKW, Groupe E, and Primeo. Requests contain no personal data. Prices are cached for 15 minutes on the server.',
      },
      {
        heading: '5. Notifications',
        body: 'If enabled, notifications are generated locally on your device; no push server in the current version.',
      },
      {
        heading: '6. Contact',
        body: 'For privacy questions, use the contact details in the app store listings.',
      },
    ],
  },
  fr: {
    title: 'Politique de confidentialité',
    updated: 'Dernière mise à jour : 1 novembre 2026',
    back: '← Retour à Swiss Energy Assistant',
    sections: [
      {
        heading: '1. Aperçu',
        body:
          'Swiss Energy Assistant (« SEA », « l’application ») affiche des prix dynamiques publics de fournisseurs suisses. Nous protégeons votre vie privée.',
      },
      {
        heading: '2. Données que nous ne collectons PAS',
        body: [
          'Aucune donnée d’identification personnelle',
          'Aucune inscription requise',
          'Pas de suivi GPS',
          'Pas d’identifiants publicitaires',
          'Pas d’analytics tiers',
          'Aucun partage avec des tiers',
        ],
      },
      {
        heading: '3. Données locales',
        body:
          'Langue, code postal, fournisseur, appareils et préférences sont stockés uniquement sur votre appareil (localStorage).',
      },
      {
        heading: '4. Réseau',
        body:
          'L’application récupère les prix via notre serveur (proxy vers les API publiques CKW, Groupe E, Primeo), sans données personnelles. Cache serveur de 15 minutes.',
      },
      {
        heading: '5. Notifications',
        body: 'Les notifications sont générées localement ; pas de serveur push dans cette version.',
      },
      {
        heading: '6. Contact',
        body: 'Questions : coordonnées indiquées dans les stores.',
      },
    ],
  },
};

const terms: Record<Locale, TermsBlock> = {
  de: {
    title: 'Nutzungsbedingungen',
    updated: 'Stand: 1. November 2026',
    back: '← Zurück zum Swiss Energy Assistant',
    sections: [
      {
        heading: '1. Betreiber',
        body: 'SEA wird betrieben von Myrax Core GmbH, Schweiz. Mit der Nutzung akzeptieren Sie diese Bedingungen.',
      },
      {
        heading: '2. Leistungsbeschreibung',
        body: 'SEA zeigt informative dynamische Strompreise aus öffentlichen Schnittstellen (u. a. SmartGridready) von CKW, Groupe E und Primeo.',
      },
      {
        heading: '3. Keine Beratung',
        body: 'Keine Finanz-, Rechts- oder Wechselberatung. Entscheidungen liegen bei Ihnen.',
      },
      {
        heading: '4. Datenqualität',
        body: 'Preise stammen von Drittanbietern; wir garantieren weder Vollständigkeit noch Richtigkeit. Rechnungen können abweichen.',
      },
      {
        heading: '5. Haftung',
        body: 'Der Dienst wird «wie besehen» bereitgestellt; Haftung im gesetzlich zulässigen Umfang ausgeschlossen.',
      },
      {
        heading: '6. Anwendbares Recht',
        body: 'Schweizer Recht; Gerichtsstand Schweiz, vorbehaltlich zwingendem Verbraucherschutz.',
      },
    ],
  },
  en: {
    title: 'Terms & Conditions',
    updated: 'Last updated: 1 November 2026',
    back: '← Back to Swiss Energy Assistant',
    sections: [
      {
        heading: '1. Operator',
        body: 'Swiss Energy Assistant is operated by Myrax Core GmbH, Switzerland. By using the Service you agree to these Terms.',
      },
      {
        heading: '2. Description of Service',
        body: 'SEA provides informational displays of dynamic prices from public provider interfaces, including SmartGridready APIs from CKW, Groupe E, and Primeo.',
      },
      {
        heading: '3. No Financial or Switching Advice',
        body: 'Nothing in the Service constitutes financial, legal, or energy-switching advice.',
      },
      {
        heading: '4. Data Accuracy',
        body: 'We do not guarantee completeness or accuracy of third-party price data.',
      },
      {
        heading: '5. Limitation of Liability',
        body: 'The Service is provided "as is"; liability is limited to the extent permitted by law.',
      },
      {
        heading: '6. Governing Law',
        body: 'These Terms are governed by Swiss law.',
      },
    ],
  },
  fr: {
    title: "Conditions d'utilisation",
    updated: 'Dernière mise à jour : 1 novembre 2026',
    back: '← Retour à Swiss Energy Assistant',
    sections: [
      {
        heading: '1. Exploitant',
        body: 'SEA est exploité par Myrax Core GmbH, Suisse. L’utilisation implique l’acceptation des présentes conditions.',
      },
      {
        heading: '2. Description',
        body: 'SEA affiche des prix dynamiques à titre informatif depuis des interfaces publiques (SmartGridready) de CKW, Groupe E et Primeo.',
      },
      {
        heading: '3. Pas de conseil',
        body: 'Aucun conseil financier, juridique ou de changement de fournisseur.',
      },
      {
        heading: '4. Exactitude',
        body: 'Les données tierces ne sont pas garanties exhaustives ou exactes.',
      },
      {
        heading: '5. Responsabilité',
        body: 'Service fourni « en l’état » ; responsabilité limitée selon la loi.',
      },
      {
        heading: '6. Droit applicable',
        body: 'Droit suisse.',
      },
    ],
  },
};

export function getPrivacyContent(locale: Locale): PrivacyBlock {
  return privacy[locale] ?? privacy.de;
}

export function getTermsContent(locale: Locale): TermsBlock {
  return terms[locale] ?? terms.de;
}

export type MethodologyBlock = {
  title: string;
  updated: string;
  back: string;
  sections: Array<{ heading: string; body: string }>;
};

const methodology: Record<Locale, MethodologyBlock> = {
  de: {
    title: 'Methodik',
    updated: 'Stand: 1. November 2026',
    back: '← Zurück zum Swiss Energy Assistant',
    sections: [
      {
        heading: 'Datenquellen',
        body: 'Preise und Tarifkomponenten stammen aus öffentlichen APIs von CKW, Groupe E und Primeo Energie, abgerufen über unseren Server.',
      },
      {
        heading: 'SmartGridready',
        body: 'Soweit verfügbar nutzen wir SmartGridready-kompatible Endpunkte für standardisierte dynamische Tarifdaten.',
      },
      {
        heading: 'Auflösung',
        body: 'Native Viertelstunden-Intervalle (96 Werte pro Tag, 15-Minuten-Auflösung) werden ohne Aggregation dargestellt.',
      },
      {
        heading: 'Server-Proxy & Cache',
        body: 'Anfragen laufen über einen serverseitigen Proxy mit 15-Minuten-Cache, um Provider-APIs zu entlasten und stabile Latenz zu bieten.',
      },
      {
        heading: 'Optimierer',
        body: 'Für Geräte empfiehlt SEA deterministische, zusammenhängende Zeitfenster mit minimalen Gesamtkosten (contiguous-window cost minimization).',
      },
      {
        heading: 'Kein Finanzrat',
        body: 'Alle Angaben sind rein informativ und ersetzen keine Rechnungs- oder Wechselberatung.',
      },
    ],
  },
  en: {
    title: 'Methodology',
    updated: 'Last updated: 1 November 2026',
    back: '← Back to Swiss Energy Assistant',
    sections: [
      {
        heading: 'Data sources',
        body: 'Prices and tariff components come from public APIs of CKW, Groupe E, and Primeo Energie, fetched via our server.',
      },
      {
        heading: 'SmartGridready',
        body: 'Where available we use SmartGridready-compatible endpoints for standardized dynamic tariff data.',
      },
      {
        heading: 'Resolution',
        body: 'Native quarter-hour intervals (96 values per day, 15-minute resolution) are shown without downsampling.',
      },
      {
        heading: 'Server proxy & cache',
        body: 'Requests go through a server-side proxy with a 15-minute cache to protect provider APIs and keep latency stable.',
      },
      {
        heading: 'Optimizer',
        body: 'For appliances, SEA recommends deterministic contiguous time windows that minimize total cost.',
      },
      {
        heading: 'No financial advice',
        body: 'All information is for illustration only and is not billing or switching advice.',
      },
    ],
  },
  fr: {
    title: 'Méthodologie',
    updated: 'Dernière mise à jour : 1 novembre 2026',
    back: '← Retour à Swiss Energy Assistant',
    sections: [
      {
        heading: 'Sources',
        body: 'Prix et composantes tarifaires via les API publiques de CKW, Groupe E et Primeo, via notre serveur.',
      },
      {
        heading: 'SmartGridready',
        body: 'Lorsque disponible, endpoints compatibles SmartGridready pour des données dynamiques standardisées.',
      },
      {
        heading: 'Résolution',
        body: 'Intervalles quart-horaires natifs (96 valeurs/jour, 15 minutes) sans agrégation.',
      },
      {
        heading: 'Proxy & cache',
        body: 'Proxy serveur avec cache de 15 minutes pour alléger les API des fournisseurs.',
      },
      {
        heading: 'Optimiseur',
        body: 'Fenêtres contiguës déterministes minimisant le coût total pour les appareils.',
      },
      {
        heading: 'Pas de conseil financier',
        body: 'Informations indicatives uniquement, pas de conseil de facturation ou de changement.',
      },
    ],
  },
};

export function getMethodologyContent(locale: Locale): MethodologyBlock {
  return methodology[locale] ?? methodology.de;
}
