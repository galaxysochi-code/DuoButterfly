'use strict';
const translations = {
ru: {
navInstall:'Установка',installLabel:'Начать просто.',installTitle:'Пара шагов.<br> И готово.',
windowsSoon:'Скоро для Windows.',
skip:'К содержимому',navStyles:'Стили',navPrivacy:'Приватность',language:'Язык',download:'Скачать бесплатно',hero1:'Ваш MacBook.',hero2:'Красивый финал.',heroCopy:'Прикройте крышку. Рабочий стол плавно изгибается, размывается и темнеет.<br> Откройте — и всё возвращается.',downloadMac:'Скачать бесплатно',seeMotion:'Посмотреть эффект',requirements:'Бесплатно · macOS 26+ · Apple silicon · Нужен датчик угла крышки',motionLabel:'Маленькое движение. Новое ощущение.',motion1:'Движется крышка.',motion2:'За ней — пиксели.',motionCopy:'Один плавный жест. От шарнира до рабочего стола.',demoCaption:'Рендер приложения · Демонстрационный рабочий стол',play:'Смотреть',pause:'Пауза',mediaError:'Видео не удалось воспроизвести. Анимация GIF доступна по ссылке внизу страницы.',stylesLabel:'Три стиля. Ваше настроение.',styles1:'Один жест.',styles2:'Разные ощущения.',silk:'Шёлк',dusk:'Сумерки',mist:'Туман',silkCopy:'Мягкий изгиб. Плавное затухание. Ничего лишнего.',duskCopy:'Более глубокие тени. Спокойный переход к темноте.',mistCopy:'Воздушное размытие. Рабочий стол словно за матовым стеклом.',stylesNote:'Настройте изгиб, размытие и затемнение в приложении.',controlLabel:'Всегда рядом. В строке меню.',control1:'Немного магии.',control2:'Под контролем.',controlCopy:'Проверьте эффект, выберите стиль и задайте угол отключения. Включайте и выключайте одним движением.',shortcutCopy:'Одно сочетание. Эффект включён. Эффект выключен.',privacyLabel:'Приватность по умолчанию.',privacy1:'Ваш экран.',privacy2:'Ваш Mac.',privacy3:'Только ваши.',privacyCopy:'Кадры обрабатываются в памяти через Metal, прямо на вашем Mac. Они не сохраняются в файлы и не отправляются в облако.',noAccount:'Без аккаунта.',noAnalytics:'Без аналитики.',noAudio:'Без захвата звука.',privacyLink:'Политика конфиденциальности приложения',install1:'Скачайте ZIP из последнего выпуска на GitHub, распакуйте и перенесите DUO Butterfly в «Программы».',install2:'Приложение не нотарифицировано Apple. После первой попытки запуска откройте «Системные настройки → Конфиденциальность и безопасность» и нажмите «Всё равно открыть».',install3:'Разрешите запись экрана по запросу. Эффекту нужен доступ к встроенному экрану; звук не захватывается.',installLink:'Инструкция по установке',final1:'Закройте MacBook.',final2:'Красиво.',free:'Бесплатно. Открытый код. Просто для удовольствия.',source:'Исходный код',support:'Поддержка',gif:'Анимация GIF',license:'Лицензия',disclaimer:'Независимый проект, не связанный с Apple Inc. MacBook и macOS — товарные знаки Apple Inc.',sitePrivacy:'На сайте нет аналитики. Выбранный язык сохраняется в вашем браузере. Хостинг — GitHub Pages.',navLabel:'Основная навигация',styleLabel:'Стиль эффекта',videoAlt:'Рендер DUO Butterfly: демонстрационный рабочий стол изгибается, размывается и темнеет, затем возвращается в исходное состояние.',appAlt:'Окно приложения DUO Butterfly',title:'DUO Butterfly — Ваш MacBook в движении.',description:'Рабочий стол плавно изгибается, размывается и темнеет вслед за крышкой MacBook. Бесплатно, с открытым кодом и локальной обработкой.'
},
es: {
navInstall:'Instalación',installLabel:'Empieza cuando quieras.',installTitle:'Unos pasos.<br> Y listo.',
windowsSoon:'Próximamente para Windows.',
skip:'Ir al contenido',navStyles:'Estilos',navPrivacy:'Privacidad',language:'Idioma',download:'Descarga gratis',hero1:'Tu MacBook.',hero2:'Un cierre diferente.',heroCopy:'Baja la tapa. Tu escritorio se curva, se desenfoca y se oscurece.<br> Ábrela de nuevo. Todo vuelve a su lugar.',downloadMac:'Descargar gratis',seeMotion:'Ver el efecto',requirements:'Gratis · macOS 26+ · Apple silicon · Requiere sensor de ángulo de tapa',motionLabel:'Un pequeño movimiento. Una nueva sensación.',motion1:'Mueve la tapa.',motion2:'Los píxeles la siguen.',motionCopy:'Un solo gesto, de la bisagra a tu escritorio.',demoCaption:'Renderizado real de la app · Escritorio de muestra',play:'Reproducir',pause:'Pausar',mediaError:'No se pudo reproducir el vídeo. Puedes ver el GIF con el enlace al pie de la página.',stylesLabel:'Tres estilos. A tu gusto.',styles1:'El mismo gesto.',styles2:'Otra sensación.',silk:'Seda',dusk:'Ocaso',mist:'Niebla',silkCopy:'Una curva suave. Un fundido sutil. Todo fluye.',duskCopy:'Sombras más profundas. Una transición serena a la oscuridad.',mistCopy:'Un desenfoque ligero, como mirar a través de un cristal esmerilado.',stylesNote:'Ajusta la curvatura, el desenfoque y la oscuridad en la app.',controlLabel:'Siempre a mano. En la barra de menús.',control1:'Un poco de magia.',control2:'A tu manera.',controlCopy:'Previsualiza el efecto, elige un estilo y ajusta el ángulo de desactivación. Actívalo o desactívalo al instante.',shortcutCopy:'Un atajo. Efecto activado. Efecto desactivado.',privacyLabel:'Privacidad desde el principio.',privacy1:'Tu pantalla.',privacy2:'Tu Mac.',privacy3:'Solo tuyos.',privacyCopy:'Los fotogramas se procesan en memoria con Metal, en tu Mac. Nunca se guardan en archivos ni se envían a la nube.',noAccount:'Sin cuenta.',noAnalytics:'Sin analíticas.',noAudio:'Sin captura de audio.',privacyLink:'Lee la política de privacidad de la app',install1:'Descarga el ZIP de la última versión en GitHub, descomprímelo y mueve DUO Butterfly a Aplicaciones.',install2:'Apple no ha notarizado la app. Tras intentar abrirla, ve a Ajustes del Sistema → Privacidad y seguridad y selecciona Abrir igualmente.',install3:'Permite la grabación de pantalla cuando se solicite. El efecto necesita acceso a la pantalla integrada; no captura audio.',installLink:'Lee la guía de instalación',final1:'Cierra tu MacBook.',final2:'Disfruta el momento.',free:'Gratis y de código abierto. Por el placer de los detalles.',source:'Ver código fuente',support:'Ayuda',gif:'Demo GIF',license:'Licencia',disclaimer:'Un proyecto independiente, no afiliado a Apple Inc. MacBook y macOS son marcas de Apple Inc.',sitePrivacy:'Esta web no usa analíticas. El idioma se guarda en tu navegador. Alojamiento: GitHub Pages.',navLabel:'Navegación principal',styleLabel:'Estilo del efecto',videoAlt:'El renderizador de DUO Butterfly curva, desenfoca y oscurece un escritorio de muestra y después lo restaura.',appAlt:'Ventana de DUO Butterfly',title:'DUO Butterfly — Tu MacBook, en movimiento.',description:'Tu escritorio se curva, se desenfoca y se oscurece al cerrar la tapa del MacBook. Gratis, de código abierto y con procesamiento local.'
},
zh: {
navInstall:'安装',installLabel:'随时开始。',installTitle:'简单几步。<br> 即刻体验。',
windowsSoon:'Windows 版即将推出。',
skip:'跳至正文',navStyles:'风格',navPrivacy:'隐私',language:'语言',download:'免费下载',hero1:'你的 MacBook。',hero2:'合上，也动人。',heroCopy:'轻合屏幕盖，桌面随之弯曲、模糊、渐暗。<br> 再次打开，一切恢复如初。',downloadMac:'免费下载',seeMotion:'观看效果',requirements:'免费 · macOS 26+ · Apple 芯片 · 需要屏幕盖角度传感器',motionLabel:'小小动作。全新感受。',motion1:'屏幕盖动了。',motion2:'像素也随之而动。',motionCopy:'一个连贯的动作，从铰链延伸到桌面。',demoCaption:'应用实际渲染 · 示例桌面',play:'播放演示',pause:'暂停',mediaError:'视频无法播放。你可以通过页脚链接查看 GIF 动画。',stylesLabel:'三种风格，随心选择。',styles1:'相同动作。',styles2:'不同心情。',silk:'丝绸',dusk:'暮色',mist:'薄雾',silkCopy:'柔和弯曲，轻盈渐隐。自然不着痕迹。',duskCopy:'阴影更深，桌面静静融入暗色。',mistCopy:'轻柔模糊，仿佛隔着一层磨砂玻璃。',stylesNote:'在应用中调整弯曲、模糊和变暗程度。',controlLabel:'静静待在菜单栏，随时为你准备。',control1:'一点魔法。',control2:'尽在掌控。',controlCopy:'预览效果、选择风格、设置停用角度。随时一键开启或关闭。',shortcutCopy:'一个快捷键，开启或关闭效果。',privacyLabel:'隐私，从设计开始。',privacy1:'你的屏幕。',privacy2:'你的 Mac。',privacy3:'只属于你。',privacyCopy:'画面通过 Metal 在 Mac 的内存中处理，不会保存为文件，也不会发送到云端。',noAccount:'无需账户。',noAnalytics:'无数据分析。',noAudio:'不捕获声音。',privacyLink:'阅读应用隐私政策',install1:'从 GitHub 最新版本下载 ZIP，解压并将 DUO Butterfly 移至“应用程序”。',install2:'应用尚未经过 Apple 公证。首次尝试打开后，前往“系统设置 → 隐私与安全性”，选择“仍要打开”。',install3:'按提示允许屏幕录制。效果需要访问内置屏幕，不会捕获声音。',installLink:'阅读安装指南',final1:'合上 MacBook。',final2:'享受这一刻。',free:'免费、开源。为细节带来一点愉悦。',source:'查看源代码',support:'支持',gif:'GIF 演示',license:'许可证',disclaimer:'独立项目，与 Apple Inc. 无关联。MacBook 和 macOS 是 Apple Inc. 的商标。',sitePrivacy:'本网站无数据分析。语言偏好保存在你的浏览器中。由 GitHub Pages 托管。',navLabel:'主导航',styleLabel:'效果风格',videoAlt:'DUO Butterfly 实际渲染：示例桌面弯曲、模糊、渐暗，然后恢复原状。',appAlt:'DUO Butterfly 应用窗口',title:'DUO Butterfly — 你的 MacBook，动起来。',description:'合上 MacBook 屏幕盖，桌面随之弯曲、模糊、渐暗。免费、开源，完全本地处理。'
}
};
const nodes = [...document.querySelectorAll('[data-i18n]')];
translations.en = Object.fromEntries(nodes.map(node => [node.dataset.i18n, node.innerHTML]));
Object.assign(translations.en, {pause:'Pause',duskCopy:'Deeper shadows. A quiet transition into darkness.',mistCopy:'An airy blur, like looking through frosted glass.',navLabel:'Main navigation',styleLabel:'Effect style',videoAlt:document.querySelector('#demo').getAttribute('aria-label'),appAlt:'DUO Butterfly application window',title:document.title,description:document.querySelector('meta[name="description"]').content});
const video = document.querySelector('#demo');
const playButton = document.querySelector('#play');
const preference = matchMedia('(prefers-reduced-motion: reduce)');
let locale = 'en';
let activeStyle = 'silk';
let loaded = false;
let manuallyPaused = false;
let visible = false;
let attemptingPlay = false;
const t = key => translations[locale][key] ?? translations.en[key] ?? key;
function syncPlayback(){
  document.querySelector('#play-label').textContent = t(video.paused ? 'play' : 'pause');
  document.querySelector('#play-symbol').textContent = video.paused ? '▶' : 'Ⅱ';
}
function showStyle(style){
  activeStyle = style;
  document.querySelectorAll('[data-style]').forEach(button=>button.setAttribute('aria-pressed',String(button.dataset.style === style)));
  const picture = document.querySelector('#style-image');
  picture.src = `assets/${style}.webp`;
  picture.alt = `${t(style)} — ${t(style+'Copy')}`;
  document.querySelector('#style-title').textContent = t(style);
  document.querySelector('#style-description').textContent = t(style+'Copy');
}
function setLanguage(language,save=false){
  locale = Object.hasOwn(translations,language) ? language : 'en';
  document.documentElement.lang = locale === 'zh' ? 'zh-Hans' : locale;
  document.querySelector('#language').value = locale;
  nodes.forEach(node=>{node.innerHTML=t(node.dataset.i18n);});
  document.title=t('title');
  document.querySelector('meta[name="description"]').content=t('description');
  for (const field of ['og:title','twitter:title']) document.querySelector(`meta[${field.startsWith('og')?'property':'name'}="${field}"]`).content=t('title');
  for (const field of ['og:description','twitter:description']) document.querySelector(`meta[${field.startsWith('og')?'property':'name'}="${field}"]`).content=t('description');
  document.querySelector('.nav').setAttribute('aria-label',t('navLabel'));
  document.querySelector('.style-selector').setAttribute('aria-label',t('styleLabel'));
  document.querySelector('.hero-down').setAttribute('aria-label',t('seeMotion'));
  video.setAttribute('aria-label',t('videoAlt'));
  const appWindow=document.querySelector('#app-window');
  appWindow.src=`assets/app-window-${locale}.webp`;
  appWindow.alt=t('appAlt');
  showStyle(activeStyle);
  syncPlayback();
  if(save)try{localStorage.setItem('duobutterfly-language',locale);}catch{}
}
let initialLanguage=(navigator.language||'en').slice(0,2).toLowerCase();
try{initialLanguage=localStorage.getItem('duobutterfly-language')||initialLanguage;}catch{}
setLanguage(initialLanguage);
document.querySelector('#language').addEventListener('change',event=>setLanguage(event.target.value,true));
document.querySelectorAll('[data-style]').forEach(button=>button.addEventListener('click',()=>showStyle(button.dataset.style)));
function loadVideo(){
  if(loaded)return;
  video.querySelectorAll('source[data-src]').forEach(source=>{source.src=source.dataset.src;});
  video.load();loaded=true;
}
async function playVideo(manual=false){
  if(attemptingPlay)return;
  attemptingPlay=true;
  loadVideo();
  try{await video.play();document.querySelector('#media-error').hidden=true;}
  catch{if(manual&&video.error)document.querySelector('#media-error').hidden=false;}
  finally{attemptingPlay=false;syncPlayback();}
}
function canAutoplay(){
  const connection=navigator.connection;
  return !preference.matches && !connection?.saveData && !['slow-2g','2g','3g'].includes(connection?.effectiveType) && connection?.type!=='cellular' && matchMedia('(min-width: 761px)').matches;
}
playButton.addEventListener('click',()=>{
  if(video.paused){manuallyPaused=false;playVideo(true);}else{manuallyPaused=true;video.pause();}
});
video.addEventListener('play',syncPlayback);
video.addEventListener('pause',syncPlayback);
video.addEventListener('error',()=>{document.querySelector('#media-error').hidden=false;syncPlayback();});
if('IntersectionObserver' in window){
  new IntersectionObserver(entries=>{
    visible=entries[0].isIntersecting;
    if(!visible)video.pause();
    else if(canAutoplay()&&!manuallyPaused&&!document.hidden)playVideo();
  },{threshold:.35}).observe(video);
  if(!preference.matches){
    document.documentElement.classList.add('motion-ready');
    const revealObserver=new IntersectionObserver(entries=>entries.forEach(entry=>{
      if(entry.isIntersecting){entry.target.classList.remove('waiting');revealObserver.unobserve(entry.target);}
    }),{threshold:.08});
    document.querySelectorAll('.reveal').forEach(node=>{node.classList.add('waiting');revealObserver.observe(node);});
  }
}
document.addEventListener('visibilitychange',()=>{
  if(document.hidden)video.pause();
  else if(visible&&canAutoplay()&&!manuallyPaused)playVideo();
});
preference.addEventListener('change',()=>{if(preference.matches)video.pause();});
