import { defineConfig } from 'astro/config';
import mermaid from 'astro-mermaid';

export default defineConfig({
  output: 'static',
  integrations: [
    mermaid({ autoTheme: false }),
  ],
});
