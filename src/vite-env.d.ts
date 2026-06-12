/// <reference types="vite/client" />

// SECURITY FIX: Properly declare VITE_ env vars so TypeScript knows about them.
// This fixes the "Property 'env' does not exist on type 'ImportMeta'" error.
// Only VITE_ prefixed vars are exposed to the browser bundle.
interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  // Add more VITE_ vars here as needed
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
