'use strict';
const translations = {
ru: {
"skip": "К содержимому",
"navStyles": "Стили",
"navPrivacy": "Приватность",
"navInstall": "Установка",
"language": "Язык",
"download": "Скачать бесплатно",
"downloadMac": "Скачать бесплатно",
"windowsSoon": "Скоро для Windows.",
"title": "DUO Butterfly — эффекты крышки MacBook для macOS",
"description": "DUO Butterfly — бесплатное macOS-приложение с открытым кодом: рабочий стол в реальном времени изгибается, размывается и темнеет вслед за крышкой MacBook.",
"hero1": "Рабочий стол движется",
"hero2": "вместе с MacBook.",
"heroCopy": "Закройте крышку — и рабочий стол в реальном времени изгибается, размывается и темнеет.<br> Откройте её снова — и всё плавно возвращается.",
"seeMotion": "Как это работает",
"requirements": "Бесплатно и с открытым кодом · macOS 26+ · Apple silicon · Нужен датчик угла крышки",
"motionLabel": "Как это работает",
"motion1": "Закройте крышку.",
"motion2": "Рабочий стол следует за ней.",
"motionCopy": "DUO Butterfly считывает реальный угол крышки MacBook и меняет рабочий стол вслед за её движением — без заранее записанной анимации.",
"demoCaption": "Настоящий рендер · Шёлк, Сумерки и Туман",
"play": "Смотреть демо",
"pause": "Пауза",
"mediaError": "Видео не воспроизводится. GIF-версия есть по ссылке внизу страницы.",
"stylesLabel": "Стили",
"styles1": "Одно движение.",
"styles2": "Три стиля.",
"silk": "Шёлк",
"dusk": "Сумерки",
"mist": "Туман",
"silkCopy": "Мягкий изгиб и лёгкое затемнение. Самый деликатный из трёх стилей.",
"duskCopy": "Более глубокие тени и заметное затемнение при закрытии крышки.",
"mistCopy": "Размытие с эффектом матового стекла.",
"stylesNote": "Выберите, как рабочий стол будет реагировать на закрытие крышки.",
"controlLabel": "Строка меню",
"control1": "Настройте эффект",
"control2": "под себя.",
"controlCopy": "Выберите стиль, отрегулируйте эффект и задайте угол крышки, при котором он отключается.",
"shortcutCopy": "Мгновенно включайте и выключайте DUO Butterfly сочетанием ⌘⌥B.",
"privacyLabel": "Приватность",
"privacy1": "Всё, что на экране,",
"privacy2": "остаётся",
"privacy3": "на вашем Mac.",
"privacyCopy": "DUO Butterfly обрабатывает кадры экрана локально, в памяти, с помощью Metal. Они не сохраняются, не загружаются и никуда не отправляются.",
"noAccount": "Без аккаунта.",
"noAnalytics": "Без аналитики.",
"noAudio": "Без записи звука.",
"privacyLink": "Политика конфиденциальности",
"installLabel": "Установка",
"installTitle": "Установка займёт<br> несколько минут.",
"installLink": "Подробная инструкция",
"install1": "Скачайте ZIP-архив из последнего выпуска на GitHub, распакуйте его и перетащите DUO Butterfly в папку «Программы».",
"install2": "Приложение не нотаризовано Apple, поэтому macOS заблокирует первый запуск. Откройте «Системные настройки» → «Конфиденциальность и безопасность» и нажмите «Все равно открыть».",
"install3": "Разрешите запись экрана, когда macOS запросит доступ. DUO Butterfly использует это разрешение только для визуального эффекта на встроенном дисплее. Приложение не записывает ни видео, ни звук.",
"final1": "Оживите",
"final2": "свой MacBook.",
"free": "Бесплатно и с открытым кодом по лицензии MIT. Не понравится — просто перетащите в Корзину.",
"source": "Исходный код на GitHub",
"support": "Поддержка",
"gif": "Демо в GIF",
"license": "Лицензия",
"disclaimer": "Независимый проект, не связанный с Apple Inc. MacBook и macOS — товарные знаки Apple Inc.",
"sitePrivacy": "На сайте нет аналитики. Выбранный язык хранится только в вашем браузере. Хостинг — GitHub Pages.",
"navLabel": "Основная навигация",
"styleLabel": "Стиль эффекта",
"videoAlt": "Крышка MacBook закрывается и открывается, а DUO Butterfly изгибает, размывает и затемняет рабочий стол в стилях Шёлк, Сумерки и Туман.",
"appAlt": "Окно приложения DUO Butterfly"
},
es: {
"skip": "Ir al contenido",
"navStyles": "Estilos",
"navPrivacy": "Privacidad",
"navInstall": "Instalación",
"language": "Idioma",
"download": "Descargar gratis",
"downloadMac": "Descargar gratis",
"windowsSoon": "Próximamente para Windows.",
"title": "DUO Butterfly — Efectos de tapa para MacBook en macOS",
"description": "DUO Butterfly es una app gratuita y de código abierto para macOS que curva, desenfoca y oscurece el escritorio en tiempo real según el ángulo de la tapa del MacBook.",
"hero1": "Tu escritorio se mueve",
"hero2": "con tu MacBook.",
"heroCopy": "Cierra la tapa y el escritorio se curva, se desenfoca y se oscurece en tiempo real.<br> Vuelve a abrirla y todo regresa suavemente a su sitio.",
"seeMotion": "Ver cómo funciona",
"requirements": "Gratis y de código abierto · macOS 26+ · Apple silicon · Requiere sensor de ángulo de la tapa",
"motionLabel": "Cómo funciona",
"motion1": "Cierra la tapa.",
"motion2": "El escritorio la sigue.",
"motionCopy": "DUO Butterfly lee el ángulo real de la tapa del MacBook y transforma el escritorio mientras se mueve, sin animaciones pregrabadas.",
"demoCaption": "Renderizado real · Seda, Crepúsculo y Niebla",
"play": "Ver demo",
"pause": "Pausa",
"mediaError": "No se ha podido reproducir el vídeo. Encontrarás la versión GIF al final de la página.",
"stylesLabel": "Estilos",
"styles1": "Un movimiento.",
"styles2": "Tres estilos.",
"silk": "Seda",
"dusk": "Crepúsculo",
"mist": "Niebla",
"silkCopy": "Una curva suave con un ligero fundido. El más sutil de los tres.",
"duskCopy": "Sombras más profundas y un oscurecimiento más marcado al cerrar la tapa.",
"mistCopy": "Un desenfoque suave, como tras un cristal esmerilado.",
"stylesNote": "Elige cómo reacciona el escritorio al cerrar la tapa.",
"controlLabel": "En la barra de menús",
"control1": "Haz que se sienta",
"control2": "a tu gusto.",
"controlCopy": "Elige un estilo, ajusta el efecto y define el ángulo de la tapa en el que se desactiva.",
"shortcutCopy": "Activa o desactiva DUO Butterfly al instante con ⌘⌥B.",
"privacyLabel": "Privacidad",
"privacy1": "Tu pantalla",
"privacy2": "no sale",
"privacy3": "de tu Mac.",
"privacyCopy": "DUO Butterfly procesa los fotogramas localmente, en memoria, con Metal. Nunca se guardan, se suben ni se envían a ningún sitio.",
"noAccount": "Sin cuenta.",
"noAnalytics": "Sin analíticas.",
"noAudio": "Sin grabar audio.",
"privacyLink": "Lee la política de privacidad",
"installLabel": "Instalación",
"installTitle": "Instálalo<br> en unos minutos.",
"installLink": "Guía de instalación detallada",
"install1": "Descarga el archivo ZIP de la última versión en GitHub, descomprímelo y arrastra DUO Butterfly a la carpeta Aplicaciones.",
"install2": "Apple no ha notarizado la app, así que macOS bloqueará la primera apertura. Ve a Ajustes del Sistema → Privacidad y seguridad y haz clic en Abrir igualmente.",
"install3": "Permite la grabación de pantalla cuando macOS lo solicite. DUO Butterfly usa este permiso solo para crear el efecto visual en la pantalla integrada. No graba vídeo ni audio.",
"final1": "Dale más vida",
"final2": "a tu MacBook.",
"free": "Gratis y de código abierto con licencia MIT. ¿No te convence? Arrástrala a la Papelera y listo.",
"source": "Código fuente en GitHub",
"support": "Soporte",
"gif": "Demo en GIF",
"license": "Licencia",
"disclaimer": "Proyecto independiente, sin relación con Apple Inc. MacBook y macOS son marcas comerciales de Apple Inc.",
"sitePrivacy": "Este sitio no usa analíticas. El idioma elegido solo se guarda en tu navegador. Alojado en GitHub Pages.",
"navLabel": "Navegación principal",
"styleLabel": "Estilo del efecto",
"videoAlt": "La tapa de un MacBook se cierra y se abre mientras DUO Butterfly curva, desenfoca y oscurece el escritorio con los estilos Seda, Crepúsculo y Niebla.",
"appAlt": "Ventana de la app DUO Butterfly"
},
zh: {
"skip": "跳至正文",
"navStyles": "风格",
"navPrivacy": "隐私",
"navInstall": "安装",
"language": "语言",
"download": "免费下载",
"downloadMac": "免费下载",
"windowsSoon": "Windows 版即将推出。",
"title": "DUO Butterfly — macOS 的 MacBook 合盖特效",
"description": "DUO Butterfly 是一款免费开源的 macOS 应用，可根据 MacBook 屏幕盖的实际角度，让桌面实时弯曲、模糊并变暗。",
"hero1": "桌面随 MacBook",
"hero2": "一起动起来。",
"heroCopy": "合上屏幕盖，桌面会实时弯曲、模糊并变暗。<br>再次打开，一切平滑恢复原样。",
"seeMotion": "了解工作原理",
"requirements": "免费开源 · macOS 26+ · Apple 芯片 · 需配备屏幕盖角度传感器",
"motionLabel": "工作原理",
"motion1": "合上屏幕盖。",
"motion2": "桌面随之变化。",
"motionCopy": "DUO Butterfly 读取 MacBook 屏幕盖的实际角度，并随其移动实时改变桌面，而不是播放预设动画。",
"demoCaption": "应用实际渲染 · 丝绸、暮色、薄雾",
"play": "播放演示",
"pause": "暂停",
"mediaError": "视频无法播放。页面底部提供 GIF 版本。",
"stylesLabel": "风格",
"styles1": "一个动作，",
"styles2": "三种风格。",
"silk": "丝绸",
"dusk": "暮色",
"mist": "薄雾",
"silkCopy": "柔和弯曲，轻轻淡出。三种风格中最含蓄的一种。",
"duskCopy": "阴影更深，合盖时变暗更明显。",
"mistCopy": "柔和的磨砂玻璃模糊效果。",
"stylesNote": "选择合上屏幕盖时桌面的响应方式。",
"controlLabel": "菜单栏应用",
"control1": "调整到",
"control2": "你喜欢的感觉。",
"controlCopy": "选择风格、调整效果，并设定屏幕盖达到哪个角度时关闭效果。",
"shortcutCopy": "按 ⌘⌥B 即可立即开启或关闭 DUO Butterfly。",
"privacyLabel": "隐私",
"privacy1": "屏幕画面",
"privacy2": "始终留在",
"privacy3": "你的 Mac 上。",
"privacyCopy": "DUO Butterfly 使用 Metal 在本机内存中处理屏幕画面。画面不会被保存、上传或发送到任何地方。",
"noAccount": "无需账户。",
"noAnalytics": "无数据分析。",
"noAudio": "不录制声音。",
"privacyLink": "阅读隐私政策",
"installLabel": "安装",
"installTitle": "几分钟<br>即可安装。",
"installLink": "详细安装指南",
"install1": "从 GitHub 最新版本下载 ZIP 文件，解压后将 DUO Butterfly 拖到“应用程序”文件夹。",
"install2": "应用未经 Apple 公证，因此 macOS 会阻止首次打开。请前往“系统设置”→“隐私与安全性”，点按“仍要打开”。",
"install3": "当 macOS 请求时，请允许屏幕录制。DUO Butterfly 仅用这项权限在内置显示屏上生成视觉效果，不会录制视频或声音。",
"final1": "让你的 MacBook",
"final2": "更加灵动。",
"free": "免费开源，采用 MIT 许可证。不喜欢？直接拖到废纸篓即可。",
"source": "在 GitHub 查看源代码",
"support": "帮助与反馈",
"gif": "GIF 演示",
"license": "许可证",
"disclaimer": "独立项目，与 Apple Inc. 无关联。MacBook 和 macOS 是 Apple Inc. 的商标。",
"sitePrivacy": "本网站不使用数据分析。语言选择仅保存在你的浏览器中。由 GitHub Pages 托管。",
"navLabel": "主导航",
"styleLabel": "效果风格",
"videoAlt": "MacBook 屏幕盖合上又打开，DUO Butterfly 依次以丝绸、暮色、薄雾风格让桌面弯曲、模糊并变暗。",
"appAlt": "DUO Butterfly 应用窗口"
}
};
const nodes = [...document.querySelectorAll('[data-i18n]')];
translations.en = Object.fromEntries(nodes.map(node => [node.dataset.i18n, node.innerHTML]));
Object.assign(translations.en, {pause:"Pause",duskCopy:"Deeper shadows and stronger dimming as the lid closes.",mistCopy:"A soft, frosted-glass blur.",navLabel:"Main navigation",styleLabel:"Effect style",appAlt:"DUO Butterfly app window",videoAlt:document.querySelector('#demo').getAttribute('aria-label'),appAlt:"DUO Butterfly app window",title:document.title,description:document.querySelector('meta[name="description"]').content});
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
