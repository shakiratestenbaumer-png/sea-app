import { Metadata } from 'next';
import LegalDocumentPage from '@/components/legal/LegalDocumentPage';
import { getTermsContent } from '@/lib/legalContent';

export const metadata: Metadata = {
  title: 'Terms & Conditions — Swiss Energy Assistant',
};

export default function TermsPage() {
  return <LegalDocumentPage getContent={getTermsContent} />;
}
