export function getTodayStr(): string {
  return new Date().toISOString().split('T')[0];
}

export function getTomorrowStr(): string {
  const d = new Date();
  d.setDate(d.getDate() + 1);
  return d.toISOString().split('T')[0];
}

export function getDateStr(which: 'today' | 'tomorrow'): string {
  return which === 'today' ? getTodayStr() : getTomorrowStr();
}

export function formatSwissTime(isoStr: string): string {
  try {
    return new Date(isoStr).toLocaleTimeString('de-CH', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: false,
      timeZone: 'Europe/Zurich',
    });
  } catch {
    return '--:--';
  }
}
