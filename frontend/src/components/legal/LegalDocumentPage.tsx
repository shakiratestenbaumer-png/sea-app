'use client';

import { useEffect, useState } from 'react';
import { detectBrowserLocale } from '@/lib/browserLocale';
import type { Locale } from '@/i18n/translations';

type Section = { heading: string; body: string | string[] };

export default function LegalDocumentPage({
  getContent,
}: {
  getContent: (locale: Locale) => {
    title: string;
    updated: string;
    back: string;
    sections: Section[];
  };
}) {
  const [locale, setLocale] = useState<Locale>('de');

  useEffect(() => {
    setLocale(detectBrowserLocale());
  }, []);

  const doc = getContent(locale);

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-3xl mx-auto px-6 py-12">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">{doc.title}</h1>
        <p className="text-sm text-gray-400 mb-6">{doc.updated}</p>

        <div className="prose prose-gray max-w-none space-y-6">
          {doc.sections.map((section) => (
            <section key={section.heading}>
              <h2 className="text-xl font-semibold text-gray-800">{section.heading}</h2>
              {Array.isArray(section.body) ? (
                <ul className="list-disc pl-6 text-gray-600 space-y-1">
                  {section.body.map((item) => (
                    <li key={item}>{item}</li>
                  ))}
                </ul>
              ) : (
                <p className="text-gray-600">{section.body}</p>
              )}
            </section>
          ))}
        </div>

        <div className="mt-12 pt-6 border-t border-gray-200 text-center">
          <a href="/" className="text-teal-600 hover:text-teal-700 font-medium">
            {doc.back}
          </a>
        </div>
      </div>
    </div>
  );
}
