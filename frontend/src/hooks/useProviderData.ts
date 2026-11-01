import { useEffect, useState } from 'react';
import { fetchAllProviders, type AllProvidersResponse, type ProviderData, type ProviderId } from '@/lib/api';

let _globalData: AllProvidersResponse | null = null;
let _globalPromise: Promise<AllProvidersResponse> | null = null;

function fetchOnce(): Promise<AllProvidersResponse> {
  if (!_globalPromise) {
    _globalPromise = fetchAllProviders().then((d) => {
      _globalData = d;
      setTimeout(() => { _globalPromise = null; }, 60_000);
      return d;
    });
  }
  return _globalPromise;
}

export function useProviderData() {
  const [data, setData] = useState<AllProvidersResponse | null>(_globalData);
  const [loading, setLoading] = useState(!_globalData);

  useEffect(() => {
    if (_globalData) {
      setData(_globalData);
      setLoading(false);
      return;
    }
    fetchOnce().then((d) => {
      setData(d);
      setLoading(false);
    });
  }, []);

  return { data, loading, providers: data?.providers ?? [] };
}

export function useProvider(id: ProviderId) {
  const { providers, loading } = useProviderData();
  const provider = providers.find((p) => p.id === id) ?? null;
  return { provider, loading };
}
