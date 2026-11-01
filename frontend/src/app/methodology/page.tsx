import { Metadata } from 'next';
import LegalDocumentPage from '@/components/legal/LegalDocumentPage';
import { getMethodologyContent } from '@/lib/legalContent';

export const metadata: Metadata = {
  title: 'Methodology — Swiss Energy Assistant',
};

export default function MethodologyPage() {
  return <LegalDocumentPage getContent={getMethodologyContent} />;
}
