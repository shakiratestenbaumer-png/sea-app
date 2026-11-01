import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { TooltipProvider } from "@/components/ui/tooltip";
import "./globals.css";
import "./grid.css";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
});

export const metadata: Metadata = {
  title: "Swiss Energy Assistant",
  description: "Understand your Swiss electricity tariff. Know the best time to run your appliances. No hardware required.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="de" className={inter.variable}>
      <head>
        <link rel="manifest" href="/manifest.json" />
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="icon" href="/icons/favicon-32x32.png" type="image/png" />
        <link rel="apple-touch-icon" href="/icons/apple-touch-icon.png" />
        <meta name="theme-color" content="#0D9488" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="default" />
      </head>
      <body className="font-sans antialiased">
        <TooltipProvider>
          {children}
        </TooltipProvider>
        <script
          dangerouslySetInnerHTML={{
            __html: `if('serviceWorker' in navigator) navigator.serviceWorker.register('/sw.js');`,
          }}
        />
      </body>
    </html>
  );
}
