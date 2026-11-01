import { Metadata } from 'next';
import LegalDocumentPage from '@/components/legal/LegalDocumentPage';
import { getPrivacyContent } from '@/lib/legalContent';

export const metadata: Metadata = {
  title: 'Privacy Policy — Swiss Energy Assistant',
};

export default function PrivacyPage() {
  return <LegalDocumentPage getContent={getPrivacyContent} />;
}
