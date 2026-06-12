import { createInertiaApp } from '@inertiajs/vue3';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import { initializeTheme } from '@/composables/useAppearance';
import AppLayout from '@/layouts/AppLayout.vue';
import AuthLayout from '@/layouts/AuthLayout.vue';
import SettingsLayout from '@/layouts/settings/Layout.vue';
import { createApp, h, type DefineComponent } from 'vue';

const appName = import.meta.env.VITE_APP_NAME || 'Laravel';

createInertiaApp({
    title: (title) => (title ? `${title} - ${appName}` : appName),
    resolve: async (name) => {
        const page = await resolvePageComponent(
            `./pages/${name}.vue`,
            import.meta.glob<DefineComponent>('./pages/**/*.vue'),
        );
        return page;
    },
    layout: (name) => {
    switch (true) {
        case name === 'Welcome':
            return null;
        case name.startsWith('barang/'):
            return null;
        case name.startsWith('riwayat/'):
            return null;
        case name.startsWith('servis/'):
            return null;
        case name.startsWith('pesanan/'):
            return null;
        case name.startsWith('auth/'):
            return AuthLayout;
        case name.startsWith('settings/'):
        case name.startsWith('teams/'):
            return [AppLayout, SettingsLayout];
        default:
            return AppLayout;
    }
},
    setup({ el, App, props, plugin }) {
    if (typeof window === 'undefined') return;
        createApp({ render: () => h(App, props) })
            .use(plugin)
            .mount(el);
    },
    progress: {
        color: '#4B5563',
    },
});

initializeTheme();