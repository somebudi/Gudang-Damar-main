<script setup lang="ts">
import { Head, Link } from '@inertiajs/vue3';
import { login, register } from '@/routes';

withDefaults(
    defineProps<{
        canRegister: boolean;
    }>(),
    {
        canRegister: true,
    },
);

const dashboardUrl = '/riwayat';
</script>

<template>
    <Head title="Gudang Damar - Peralatan Dapur Berkualitas">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
    </Head>

    <div class="welcome-theme min-h-screen bg-[#f9f9f9] text-stone-900 antialiased selection:bg-[#f3c99b] selection:text-stone-900">
        <!-- TopNavBar Component -->
        <nav class="fixed top-0 w-full z-50 bg-[#66ACE6]/90 backdrop-blur-md shadow-sm">
            <div class="max-w-2560 mx-auto flex justify-between items-center px-8 h-20">
                <div class="text-2xl font-bold tracking-tighter text-white">
                    Gudang Damar
                </div>

                <div class="flex items-center space-x-4 text-white">
                    <Link
                        v-if="$page.props.auth.user"
                        
                        :href="dashboardUrl"
                        class="inline-flex items-center justify-center px-5 py-2 text-sm font-semibold bg-white text-[#4F9BD1] rounded-md hover:bg-[#EAF4FD] transition-colors shadow-sm"
                    >
                        Dashboard
                    </Link>
                    <template v-else>
                        <Link
                            :href="login()"
                            class="text-sm text-white/90 hover:text-white transition-colors"
                        >
                            Log in
                        </Link>
                        <Link
                            v-if="canRegister"
                            :href="register()"
                            class="inline-flex items-center justify-center px-5 py-2 text-sm font-semibold bg-white text-[#4F9BD1] rounded-md hover:bg-[#EAF4FD] transition-colors shadow-sm"
                        >
                            Register
                        </Link>
                    </template>


                    
                </div>
            </div>
        </nav>
        
        <main class="pt-20">
            <!-- Hero Section -->
            <section class="max-w-container-max mx-auto px-margin-mobile md:px-margin-desktop py-section-gap flex flex-col md:flex-row items-center gap-gutter min-h-204.75">
                <div class="w-full md:w-1/2 space-y-6 z-10 pr-0 md:pr-12">
                <h1 class="font-display-xl text-display-xl text-on-surface">
                                    Peralatan Dapur Berkualitas untuk Masakan Sempurna
                                </h1>
                <p class="font-body-lg text-body-lg text-on-surface-variant max-w-lg">
                                    Lengkapi dapur Anda dengan peralatan masak berkesan custom. Desain minimalis, fungsionalitas maksimal.
                                </p>
                <div class="pt-4">
                <a class="inline-flex items-center justify-center px-8 py-4 bg-[#66ACE6] text-white font-label-sm text-label-sm uppercase tracking-wider rounded-DEFAULT hover:bg-[#4F9BD1] transition-colors shadow-sm hover:shadow-md" href="#produk">
                                        Jelajahi Koleksi
                                    </a>
                </div>
                </div>
                <div class="w-full md:w-1/2 relative h-125 md:h-175 rounded-xl overflow-hidden shadow-[0_20px_40px_-15px_rgba(17,17,17,0.06)]">
                <img alt="High-quality cooking utensils" class="absolute inset-0 w-full h-full object-cover" data-alt="Modern kitchen interior with sleek minimal wooden and stainless steel cooking utensils neatly arranged on a clean marble countertop, soft natural daylight, warm inviting atmosphere" src="https://lh3.googleusercontent.com/aida-public/AB6AXuDJPUpY3d-2v4U0vx3WpCAGV4kF_010O4MLILB97vTQprd3PTx51NN-8xJ-9_l7U8HOaSTbjfw1KfimKecPtSQpqUYInts5b3jrmKVYgIwwc-1O2-mVrAxx7P_66aRMW7Sp7PgNklmaK_uLMjY2PfRw2bs-8sznozN_cebAT2Kt53SbaPgsrG-4dOgnI9GNswY9HGxoAuJ_jbr2E3cVBQAGAFiwykCto3G4GJ6oJRQFZQk4qwtQB99rdcXMrtqsPJE8vBbJV_-E1Vo"/>
                </div>
            </section>
            <!-- Produk Unggulan Section -->
            <section class="bg-surface-container-low py-section-gap" id="produk">
            <div class="max-w-container-max mx-auto px-margin-mobile md:px-margin-desktop">
            <div class="mb-16 md:mb-24">
            <h2 class="font-headline-lg text-headline-lg text-on-surface mb-4">Produk Unggulan</h2>
            <p class="font-body-md text-body-md text-on-surface-variant max-w-2xl">Koleksi kurasi kami dirancang untuk meningkatkan pengalaman memasak Anda, memadukan estetika dan ketahanan.</p>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-gutter">


            <!-- Card 1 -->
            <div class="group flex flex-col gap-4 rounded-2xl overflow-hidden bg-white shadow-sm hover:shadow-xl transition-all duration-300">

            <!-- IMAGE -->
            <div class="relative aspect-4/5 overflow-hidden">
                
                <img 
                src="/gambar/panci3.png"
                alt="Peralatan Masak"
                class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                />

                <!-- overlay gelap biar teks kebaca -->
                <div class="absolute inset-0 bg-linear-to-t from-black/50 via-black/10 to-transparent opacity-80"></div>

                <!-- badge -->
                <div class="absolute top-4 left-4 bg-white/90 backdrop-blur px-3 py-1.5 rounded-full text-[11px] font-semibold text-stone-800 shadow">
                Peralatan Masak
                </div>

            </div>

            <!-- CONTENT -->
            <div class="px-4 pb-5">
                <h3 class="text-[18px] font-semibold text-stone-900 group-hover:text-[#1371be] transition-colors">
                Set Panci & Wajan
                </h3>

                <p class="text-sm text-stone-500 mt-2 leading-relaxed">
                Material tahan karat dengan distribusi panas merata.
                </p>
            </div>

            </div>
            <!-- Card 2 -->
            <div class="group flex flex-col gap-4 rounded-2xl overflow-hidden bg-white shadow-sm hover:shadow-xl transition-all duration-300">

            <!-- IMAGE -->
            <div class="relative aspect-4/5 overflow-hidden">
                
                <img 
                src="/gambar/loyangkue.png"
                alt="Peralatan Masak"
                class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                />

                <!-- overlay gelap biar teks kebaca -->
                <div class="absolute inset-0 bg-linear-to-t from-black/50 via-black/10 to-transparent opacity-80"></div>

                <!-- badge -->
                <div class="absolute top-4 left-4 bg-white/90 backdrop-blur px-3 py-1.5 rounded-full text-[11px] font-semibold text-stone-800 shadow">
                Peralatan Baking
                </div>

            </div>

            <!-- CONTENT -->
            <div class="px-4 pb-5">
                <h3 class="text-[18px] font-semibold text-stone-900 group-hover:text-[#1371be] transition-colors">
                Loyang Kue
                </h3>

                <p class="text-sm text-stone-500 mt-2 leading-relaxed">
                Anti lengket, mudah dibersihkan untuk hasil panggangan sempurna.
                </p>
            </div>

            </div>
            <!-- Card 3 -->
            <div class="group flex flex-col gap-4 rounded-2xl overflow-hidden bg-white shadow-sm hover:shadow-xl transition-all duration-300">

            <!-- IMAGE -->
            <div class="relative aspect-4/5 overflow-hidden">
                
                <img 
                src="/gambar/dandang.jpg"
                alt="Peralatan Masak"
                class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                />

                <!-- overlay gelap biar teks kebaca -->
                <div class="absolute inset-0 bg-linear-to-t from-black/50 via-black/10 to-transparent opacity-80"></div>

                <!-- badge -->
                <div class="absolute top-4 left-4 bg-white/90 backdrop-blur px-3 py-1.5 rounded-full text-[11px] font-semibold text-stone-800 shadow">
                Peralatan Masak
                </div>

            </div>

            <!-- CONTENT -->
            <div class="px-4 pb-5">
                <h3 class="text-[18px] font-semibold text-stone-900 group-hover:text-[#1371be] transition-colors">
                Dandang Kukus
                </h3>

                <p class="text-sm text-stone-500 mt-2 leading-relaxed">
                 Cocok untuk mengukus berbagai makanan dengan panas merata, menjaga tekstur dan rasa tetap optimal.
                </p>
            </div>

            
            </div>
            </div>
            </div>
            </section>
            <!-- Why Us Section -->
            <section class="py-section-gap bg-surface">
            <div class="max-w-container-max mx-auto px-margin-mobile md:px-margin-desktop">
            <div class="text-center mb-16 md:mb-24">
            <h2 class="font-headline-lg text-headline-lg text-on-surface">Keunggulan Gudang Damar</h2>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-12">
            <div class="flex flex-col items-center text-center gap-4">
            <div class="w-16 h-16 rounded-full bg-secondary-container flex items-center justify-center text-on-secondary-container">
            <span class="material-symbols-outlined text-3xl" data-icon="local_fire_department">local_fire_department</span>
            </div>
            <h4 class="font-headline-md text-[20px] leading-tight text-on-surface">Tahan Panas &amp; Awet</h4>
            <p class="font-body-md text-body-md text-on-surface-variant">Material premium yang dirancang untuk penggunaan jangka panjang di dapur profesional maupun rumahan.</p>
            </div>
            <div class="flex flex-col items-center text-center gap-4">
            <div class="w-16 h-16 rounded-full bg-secondary-container flex items-center justify-center text-on-secondary-container">
            <span class="material-symbols-outlined text-3xl" data-icon="pan_tool_alt">pan_tool_alt</span>
            </div>
            <h4 class="font-headline-md text-[20px] leading-tight text-on-surface">Fungsional &amp; Ergonomis</h4>
            <p class="font-body-md text-body-md text-on-surface-variant">Desain yang memprioritaskan kenyamanan genggaman dan kemudahan manuver saat memasak.</p>
            </div>
            <div class="flex flex-col items-center text-center gap-4">
            <div class="w-16 h-16 rounded-full bg-secondary-container flex items-center justify-center text-on-secondary-container">
            <span class="material-symbols-outlined text-3xl" data-icon="category">category</span>
            </div>
            <h4 class="font-headline-md text-[20px] leading-tight text-on-surface">Lengkap &amp; Variatif</h4>
            <p class="font-body-md text-body-md text-on-surface-variant">Menyediakan berbagai macam kebutuhan dari alat masak dasar hingga perlengkapan khusus baking.</p>
            </div>
            <div class="flex flex-col items-center text-center gap-4">
            <div class="w-16 h-16 rounded-full bg-secondary-container flex items-center justify-center text-on-secondary-container">
            <span class="material-symbols-outlined text-3xl" data-icon="payments">payments</span>
            </div>
            <h4 class="font-headline-md text-[20px] leading-tight text-on-surface">Harga Terjangkau</h4>
            <p class="font-body-md text-body-md text-on-surface-variant">Kualitas bintang lima dengan harga yang bersahabat untuk menyempurnakan dapur impian Anda.</p>
            </div>
            </div>
            </div>
            </section>

            <!-- Landing Section -->
            <section class="py-section-gap bg-[#f3f3f3]">
            <div class="max-w-container-max mx-auto px-margin-mobile md:px-margin-desktop">
                <div class="container-landing">

                <!-- KIRI: GALERI -->
                <div class="gallery-section">
                    <h2 class="font-headline-lg text-headline-lg text-on-surface">Galeri Produk</h2>

                    <div class="gallery">
                    <div class="g-card big">
                        <img src="/gambar/panci2.jpg" alt="Kitchen">
                    </div>

                    <div class="g-card">
                        <img src="/gambar/alat masak.png" alt="Cooking">
                    </div>

                    <div class="g-card">
                        <img src="/gambar/mangkok.png" alt="Utensils">
                    </div>

                    <div class="g-card">
                        <img src="/gambar/saringan.jpg" alt="Pan">
                    </div>

                    <div class="g-card">
                        <img src="/gambar/panci.jpg" alt="Kitchen Tools">
                    </div>

                    
                    </div>
                </div>

                <!-- KANAN: CARD AI -->
                <div class="right-section w-full lg:w-120 shrink-0 lg:ml-auto">
                    <div class="relative bg-linear-to-br from-[#8FC4F0] via-[#66ACE6] to-[#4F9BD1] rounded-3xl p-6 sm:p-8 flex items-center overflow-hidden shadow-xl w-full">
                        
                        <div class="relative z-10 flex-1 w-[55%]">
                            <!-- Badge -->
                            <div class="inline-block bg-white text-stone-800 text-[11px] font-bold px-3 py-1.5 rounded-full mb-4 shadow-sm">
                                Custom & AI Feature
                            </div>
                            
                            <!-- Title -->
                            <h3 class="text-white text-[22px] font-bold mb-6 leading-tight">
                                Layanan Custom Furniture
                            </h3>
                            
                            <!-- Features -->
                            <div class="space-y-5">
                                <!-- Feature 1 -->
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full bg-[#EAF4FD] flex items-center justify-center shrink-0 shadow-sm">
                                        <span class="material-symbols-outlined text-[#4F9BD1] text-[20px]">hub</span>
                                    </div>
                                    <div>
                                        <h4 class="text-white text-[13px] font-bold leading-tight mb-0.5">AI Preview</h4>
                                        <p class="text-white/80 text-[11px] leading-tight">Preview desain otomatis</p>
                                    </div>
                                </div>
                                
                                <!-- Feature 2 -->
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full bg-[#EAF4FD] flex items-center justify-center shrink-0 shadow-sm">
                                        <span class="material-symbols-outlined text-[#4F9BD1] text-[20px]">monetization_on</span>
                                    </div>
                                    <div>
                                        <h4 class="text-white text-[13px] font-bold leading-tight mb-0.5">Transparent Pricing</h4>
                                        <p class="text-white/80 text-[11px] leading-tight">Menghitung harga sesuai desain</p>
                                    </div>
                                </div>
                                
                                <!-- Feature 3 -->
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full bg-[#EAF4FD] flex items-center justify-center shrink-0 shadow-sm">
                                        <span class="material-symbols-outlined text-[#4F9BD1] text-[20px]">support_agent</span>
                                    </div>
                                    <div>
                                        <h4 class="text-white text-[13px] font-bold leading-tight mb-0.5">Konsultasi Desain</h4>
                                        <p class="text-white/80 text-[11px] leading-tight">Mudah mewujudkan bentuk impian</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Graphic Right Side -->
                        <div class="relative z-10 w-[45%] flex justify-end pl-2">
                            <div class="relative w-37.5 h-42.5 bg-linear-to-br from-[#F4F9FE] to-[#EAF4FD] rounded-3xl shadow-lg flex flex-col items-center justify-center border border-white/50">
                                
                                <!-- Cooking Icon (Replacing Avatar) -->
                                <div class="relative z-10 flex flex-col items-center mt-4 mb-2">
                                    <div class="w-18 h-18 bg-[#ffffff] rounded-full border-2 border-[#66ACE6]/30 flex items-center justify-center relative z-10 shadow-inner">
                                        <span class="material-symbols-outlined text-[#1a1a1a] text-[36px]">soup_kitchen</span>
                                    </div>
                                </div>

                                <!-- Floating badge 1 (Top right) -->
                                <div class="absolute -top-3 -right-3 w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-xl border border-stone-200">
                                    <span class="material-symbols-outlined text-[#4F9BD1] text-[20px]">draw</span>
                                </div>

                                <!-- Floating badge 2 (Left middle) -->
                                <div class="absolute top-[35%] -left-5 w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-xl border border-stone-200">
                                    <span class="material-symbols-outlined text-[#4F9BD1] text-[20px]">image</span>
                                </div>

                                <!-- Floating badge 3 (Bottom left) -->
                                <div class="absolute bottom-5 -left-4 w-10 h-10 bg-white rounded-xl flex items-center justify-center shadow-xl border border-stone-200">
                                    <span class="material-symbols-outlined text-[#4F9BD1] text-[20px]">show_chart</span>
                                </div>

                                <!-- Plant Graphic (Bottom Right) -->
                                <div class="absolute -bottom-4 -right-5">
                                    <svg width="70" height="80" viewBox="0 0 50 60" fill="none" xmlns="http://www.w3.org/2000/svg">
                                        <!-- Leaves -->
                                        <path d="M25 45 C10 30 5 15 18 10 C25 25 25 45 25 45 Z" fill="#ffffff" stroke="#1a1a1a" stroke-width="1.5" stroke-linejoin="round"/>
                                        <path d="M25 45 C40 30 45 15 32 10 C25 25 25 45 25 45 Z" fill="#ffffff" stroke="#1a1a1a" stroke-width="1.5" stroke-linejoin="round"/>
                                        <path d="M25 45 C25 25 35 5 48 5 C35 20 25 45 25 45 Z" fill="#ffffff" stroke="#1a1a1a" stroke-width="1.5" stroke-linejoin="round"/>
                                        <path d="M25 45 C25 25 15 5 2 5 C15 20 25 45 25 45 Z" fill="#ffffff" stroke="#1a1a1a" stroke-width="1.5" stroke-linejoin="round"/>
                                        <!-- Pot -->
                                        <path d="M15 45 L35 45 L31 56 L19 56 Z" fill="#ffffff" stroke="#1a1a1a" stroke-width="1.5" stroke-linejoin="round"/>
                                        <!-- Pot rim -->
                                        <rect x="13" y="42" width="24" height="4" rx="2" fill="#ffffff" stroke="#1a1a1a" stroke-width="1.5"/>
                                        <!-- Pot shadow/base -->
                                        <path d="M18 58 L32 58" stroke="#1a1a1a" stroke-width="2" stroke-linecap="round"/>
                                    </svg>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>

                </div>

                <div class="testimoni-section">
                <h2 class="font-headline-lg text-headline-lg text-on-surface">Testimoni</h2>

                <div class="testimoni">

                    <div class="card-testi">
                    <p>
                         "Kita tidak boleh tergantung pada barang asing. Ini produk lokal, kualitasnya kuat, dan saya apresiasi."
                    </p>
                    <div class="user">
                        <img src="/gambar/wowo_gaming.jpg" alt="User 1">

                        <div class="user-info">
                        <strong class="text-on-surface">wowo</strong>
                        <span>Penguasa Sawit</span>
                        </div>
                    </div>
                    </div>

                    <div class="card-testi">
                    <p>
                        "Ya ndak tau kok tanya saya... tapi yang jelas ini rapi, sederhana, dan bisa dipakai dengan baik."
                    </p>
                    <div class="user">
                        <img src="/gambar/owi.jpeg" alt="User 2">
                        <div class="user-info">
                        <strong class="text-on-surface">jack owi</strong>
                        <span>Pengusaha Kayu</span>
                        </div>
                    </div>
                    </div>

                    <div class="card-testi">
                    <p>
                        "Saya lihat ini bagus. Tinggal diolah dengan baik, pemasangan rapi, hasilnya maksimal dan langsung terasa manfaatnya."
                    </p>
                    <div class="user">
                        <img src="/gambar/lil bah.jpeg" alt="User 3">
                        <div class="user-info">
                        <strong class="text-on-surface">Lil Bah</strong>
                        <span>Dj Interior</span>
                        </div>
                    </div>
                    </div>

                </div>
                </div>
            </div>
            </section>

            <!-- CTA Section -->
            <section class="py-section-gap bg-[#66ACE6] via-[#4F9BD1] to-[#3B82C4] relative overflow-hidden">
            <div class="absolute inset-0 bg-black/10"></div>
            <div class="absolute inset-0 opacity-10 pointer-events-none">
            <img alt="Background texture" class="w-full h-full object-cover" data-alt="Subtle dark moody kitchen environment, softly blurred out background, dim warm light reflecting off dark wood and steel surfaces" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBgXMKs3bkf0KYqaVgUrfRAiWcMLsxdEpw2HCJKVTQdmX_1eYM3OF3Knv0LF-QPZzFeWQ_tkaH8YUSIpZZTfpUj_UfVrz29lGawJdmhmnqTEbKJl9fTIK7xwiwJ36NAbYWRo93twdl5u_8W3dCzpbEBJxULv5RLFfyfbSn5Sc8FnP5J_WE2VqwK5KG64hxV1GptQ52vflJVzGIfe-lnys0xsfy9pzRxz0cdCF7GBAhJcRS9ZBVRdAPsWAv8jPSQdNIrxTLfXCE7KgI"/>
            </div>
            <div class="max-w-container-max mx-auto px-margin-mobile md:px-margin-desktop relative z-10 text-center">
            <h2 class="font-display-xl text-[48px] md:text-display-xl text-white mb-6 max-w-3xl mx-auto">
                                Lengkapi Peralatan Dapur Anda Sekarang
                            </h2>
            <div class="flex flex-col sm:flex-row justify-center gap-4 mt-12">
            <a class="inline-flex items-center justify-center px-8 py-4 bg-white text-[#4F9BD1] font-label-sm text-label-sm uppercase tracking-wider rounded-DEFAULT hover:bg-[#EAF4FD] transition-colors" href="#">
                                    Belanja Sekarang
                                </a>
            <a class="inline-flex items-center justify-center px-8 py-4 bg-transparent border border-white text-white font-label-sm text-label-sm uppercase tracking-wider rounded-DEFAULT hover:bg-white/10  transition-colors" href="#">
                                    Hubungi Kami
                                </a>
            </div>
            </div>
            </section>
        </main>
        <!-- Footer  -->
        <footer class="bg-stone-100 w-full py-20 mt-32 border-t border-stone-200">
        <div class="max-w-[1280px] mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 px-8">
        <div class="flex flex-col gap-6">
        <div class="text-xl font-bold text-stone-900">
                            Gudang Damar
                        </div>
        <p class="font-sans text-xs tracking-wide text-stone-500 max-w-xs">
                            Menyediakan peralatan dapur premium yang memadukan keindahan fungsional dan ketahanan material untuk setiap kreasi kuliner Anda.
                        </p>
        </div>
        <div class="flex flex-col gap-4">
        <h4 class="font-sans text-xs tracking-wide font-bold text-stone-900 uppercase">Tautan Bantuan</h4>
        <a class="font-sans text-xs tracking-wide text-stone-500 hover:text-stone-900 underline underline-offset-4 opacity-100 hover:opacity-80 transition-opacity" href="#">Kebijakan Privasi</a>
        <a class="font-sans text-xs tracking-wide text-stone-500 hover:text-stone-900 underline underline-offset-4 opacity-100 hover:opacity-80 transition-opacity" href="#">Syarat &amp; Ketentuan</a>
        <a class="font-sans text-xs tracking-wide text-stone-500 hover:text-stone-900 underline underline-offset-4 opacity-100 hover:opacity-80 transition-opacity" href="#">Pengiriman</a>
        <a class="font-sans text-xs tracking-wide text-stone-500 hover:text-stone-900 underline underline-offset-4 opacity-100 hover:opacity-80 transition-opacity" href="#">FAQ</a>
        </div>
        <div class="flex flex-col gap-4">
        <h4 class="font-sans text-xs tracking-wide font-bold text-stone-900 uppercase">Kontak</h4>
        <p class="font-sans text-xs tracking-wide text-stone-500">Jl. Dapur Sejahtera No. 45<br/>Jakarta Selatan, 12345</p>
        <p class="font-sans text-xs tracking-wide text-stone-500">halo@gudangdamar.com</p>
        </div>
        <div class="flex flex-col gap-4">
        <h4 class="font-sans text-xs tracking-wide font-bold text-stone-900 uppercase">Ikuti Kami</h4>
        <div class="flex gap-4">
        <a class="text-stone-500 hover:text-stone-900 opacity-100 hover:opacity-80 transition-opacity" href="#">
        <span class="material-symbols-outlined" data-icon="photo_camera">photo_camera</span>
        </a>
        <a class="text-stone-500 hover:text-stone-900 opacity-100 hover:opacity-80 transition-opacity" href="#">
        <span class="material-symbols-outlined" data-icon="forum">forum</span>
        </a>
        </div>
        </div>
        </div>
        <div class="max-w-[1280px] mx-auto px-8 mt-16 pt-8 border-t border-stone-200/50">
        <p class="font-sans text-xs tracking-wide text-stone-500 text-center md:text-left">
                        © 2024 Gudang Damar. Crafting Kitchen Excellence.
                    </p>
        </div>
        </footer>
    </div>
</template>

<style scoped>
body { font-family: 'Inter', sans-serif; }

.welcome-theme {
    --color-on-surface-variant: #444748;
    --color-secondary: #78583b;
    --color-tertiary: #14100b;
    --color-surface-container-low: #e8edf2;
    --color-secondary-fixed-dim: #e8bf9b;
    --color-primary-container: #262626;
    --color-error-container: #ffdad6;
    --color-surface-tint: #5f5e5e;
    --color-on-primary-fixed-variant: #474746;
    --color-tertiary-container: #2a2520;
    --color-on-primary-container: #8e8d8c;
    --color-on-secondary-container: #4F9BD1;
    --color-on-secondary-fixed: #2c1602;
    --color-tertiary-fixed-dim: #cec5bc;
    --color-on-surface: #1a1c1c;
    --color-on-secondary: #ffffff;
    --color-primary-fixed: #e4e2e1;
    --color-on-secondary-fixed-variant: #5e4126;
    --color-on-error-container: #93000a;
    --color-on-tertiary-container: #938c84;
    --color-surface: #f9f9f9;
    --color-surface-bright: #f9f9f9;
    --color-surface-container-lowest: #ffffff;
    --color-inverse-on-surface: #f0f1f1;
    --color-background-landing: #f9f9f9;
    --color-primary-fixed-dim: #c8c6c5;
    --color-inverse-primary: #c8c6c5;
    --color-surface-dim: #dadada;
    --color-on-error: #ffffff;
    --color-inverse-surface: #2f3131;
    --color-on-background: #1a1c1c;
    --color-outline-variant: #c4c7c7;
    --color-on-primary: #ffffff;
    --color-surface-container-high: #e8e8e8;
    --color-secondary-container: #EAF4FD;
    --color-surface-container: #eeeeee;
    --color-surface-container-highest: #e2e2e2;
    --color-error: #ba1a1a;
    --color-primary: #111111;
    --color-outline: #747878;
    --color-on-tertiary: #ffffff;
    --color-on-tertiary-fixed: #1f1b16;
    --color-surface-variant: #e2e2e2;
    --color-on-primary-fixed: #1b1c1c;
    --color-tertiary-fixed: #ebe1d8;
    --color-secondary-fixed: #ffdcc0;
    --color-on-tertiary-fixed-variant: #4c463f;

    --spacing-gutter: 24px;
    --spacing-section-gap: 120px;
    --spacing-container-max: 1280px;
    --spacing-margin-mobile: 16px;
    --spacing-base: 8px;
    --spacing-margin-desktop: 64px;

    --font-body-lg: Inter, sans-serif;
    --font-body-md: Inter, sans-serif;
    --font-label-sm: Inter, sans-serif;
    --font-headline-md: Inter, sans-serif;
    --font-display-xl: Inter, sans-serif;
    --font-headline-lg: Inter, sans-serif;

    --text-body-lg: 18px;
    --text-body-lg--line-height: 28px;
    --text-body-lg--font-weight: 400;

    --text-body-md: 16px;
    --text-body-md--line-height: 24px;
    --text-body-md--font-weight: 400;

    --text-label-sm: 12px;
    --text-label-sm--line-height: 16px;
    --text-label-sm--letter-spacing: 0.05em;
    --text-label-sm--font-weight: 600;

    --text-headline-md: 24px;
    --text-headline-md--line-height: 32px;
    --text-headline-md--font-weight: 500;

    --text-display-xl: 64px;
    --text-display-xl--line-height: 72px;
    --text-display-xl--letter-spacing: -0.02em;
    --text-display-xl--font-weight: 600;

    --text-headline-lg: 32px;
    --text-headline-lg--line-height: 40px;
    --text-headline-lg--letter-spacing: -0.01em;
    --text-headline-lg--font-weight: 500;
}

.welcome-theme .text-on-surface { color: var(--color-on-surface); }
.welcome-theme .text-on-surface-variant { color: var(--color-on-surface-variant); }
.welcome-theme .bg-surface-container-low { background-color: var(--color-surface-container-low); }
.welcome-theme .bg-surface { background-color: var(--color-surface); }
.welcome-theme .bg-secondary-container { background-color: var(--color-secondary-container); }
.welcome-theme .text-on-secondary-container { color: var(--color-on-secondary-container); }
.welcome-theme .hover\:bg-secondary:hover { background-color: var(--color-secondary); }

.welcome-theme .font-display-xl { font-family: var(--font-display-xl); }
.welcome-theme .font-body-lg { font-family: var(--font-body-lg); }
.welcome-theme .font-label-sm { font-family: var(--font-label-sm); }
.welcome-theme .font-headline-lg { font-family: var(--font-headline-lg); }
.welcome-theme .font-body-md { font-family: var(--font-body-md); }
.welcome-theme .font-headline-md { font-family: var(--font-headline-md); }

.welcome-theme .text-display-xl {
    font-size: var(--text-display-xl);
    line-height: var(--text-display-xl--line-height);
    letter-spacing: var(--text-display-xl--letter-spacing);
    font-weight: var(--text-display-xl--font-weight);
}
.welcome-theme .text-body-lg {
    font-size: var(--text-body-lg);
    line-height: var(--text-body-lg--line-height);
    font-weight: var(--text-body-lg--font-weight);
}
.welcome-theme .text-label-sm {
    font-size: var(--text-label-sm);
    line-height: var(--text-label-sm--line-height);
    letter-spacing: var(--text-label-sm--letter-spacing);
    font-weight: var(--text-label-sm--font-weight);
}
.welcome-theme .text-headline-lg {
    font-size: var(--text-headline-lg);
    line-height: var(--text-headline-lg--line-height);
    letter-spacing: var(--text-headline-lg--letter-spacing);
    font-weight: var(--text-headline-lg--font-weight);
}
.welcome-theme .text-body-md {
    font-size: var(--text-body-md);
    line-height: var(--text-body-md--line-height);
    font-weight: var(--text-body-md--font-weight);
}
.welcome-theme .text-headline-md {
    font-size: var(--text-headline-md);
    line-height: var(--text-headline-md--line-height);
    font-weight: var(--text-headline-md--font-weight);
}

.welcome-theme .max-w-container-max { max-width: var(--spacing-container-max); }
.welcome-theme .px-margin-mobile { padding-left: var(--spacing-margin-mobile); padding-right: var(--spacing-margin-mobile); }
@media (min-width: 768px) {
    .welcome-theme .md\:px-margin-desktop { padding-left: var(--spacing-margin-desktop); padding-right: var(--spacing-margin-desktop); }
}
.welcome-theme .py-section-gap { padding-top: var(--spacing-section-gap); padding-bottom: var(--spacing-section-gap); }
.welcome-theme .gap-gutter { gap: var(--spacing-gutter); }

/* CSS from Landing.html */
.container-landing {
    display: flex;
    gap: 30px;
    align-items: flex-start;
}

.gallery-section { flex: 2; }
.gallery-section h2 { margin-bottom: 20px; font-size: 24px; font-weight: bold; }
.gallery { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; }
.g-card { background: #ddd; border-radius: 12px; overflow: hidden; aspect-ratio: 1; }
.g-card img { width: 100%; height: 100%; object-fit: cover; }
.big { grid-column: span 2; grid-row: span 2; }
.wide { grid-column: span 2; }



.testimoni-section { margin-top: 50px; }
.testimoni-section h2 { margin-bottom: 20px; font-size: 24px; font-weight: bold; }
.testimoni { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
.card-testi { background: white; border-radius: 16px; padding: 20px; display: flex;flex-direction: column; height: 100%; }
.card-testi p {  flex-grow: 1;font-size: 14px; color: #555; margin-bottom: 20px; }
.user { margin-top: auto;display: flex; align-items: center; gap: 10px; }
.user img { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; }
.user-info strong { display: block; font-size: 14px; }
.user-info span { font-size: 12px; color: #888; }

@media (max-width: 768px) {
    .container-landing { flex-direction: column; }
    .gallery { grid-template-columns: repeat(2, 1fr); }
    .testimoni { grid-template-columns: 1fr; }
}
</style>

