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
"title": "DUO Butterfly — эффект закрытия крышки MacBook",
"description": "Бесплатная программа для MacBook: пока вы опускаете крышку, рабочий стол изгибается, размывается и темнеет. Всё работает прямо на вашем Mac.",
"hero1": "Опускаете крышку —",
"hero2": "экран уходит красиво.",
"heroCopy": "DUO Butterfly — бесплатная программа для MacBook. Пока крышка опускается, рабочий стол плавно изгибается, размывается и темнеет.<br> Откроете — всё на своих местах.",
"seeMotion": "Посмотреть в действии",
"requirements": "Бесплатно · macOS 26 и новее · Apple silicon · Нужен датчик угла крышки",
"motionLabel": "Как это работает",
"motion1": "Крышка движется.",
"motion2": "Эффект — вместе с ней.",
"motionCopy": "Программа считывает встроенный датчик угла крышки. Чем ниже крышка, тем сильнее эффект. Остановитесь на полпути — остановится и изображение.",
"demoCaption": "Настоящий рендер · Демонстрационный рабочий стол",
"play": "Смотреть демо",
"pause": "Пауза",
"mediaError": "Видео не воспроизводится. GIF-версия есть по ссылке внизу страницы.",
"stylesLabel": "Три стиля",
"styles1": "Одно движение.",
"styles2": "Три настроения.",
"silk": "Шёлк",
"dusk": "Сумерки",
"mist": "Туман",
"silkCopy": "Мягкий изгиб и плавное затемнение. Самый деликатный из трёх.",
"duskCopy": "Глубокие тени. Рабочий стол медленно погружается в темноту.",
"mistCopy": "Размытие, как за матовым стеклом. Всё на экране становится мягче.",
"stylesNote": "Изгиб, размытие и затемнение настраиваются в программе по отдельности.",
"controlLabel": "Строка меню",
"control1": "Все настройки —",
"control2": "в один клик.",
"controlCopy": "Выберите стиль, проверьте его ползунком и задайте угол, после которого эффект исчезает. Можно включить звук при открытии крышки и автозапуск.",
"shortcutCopy": "Включайте и выключайте эффект из любой программы.",
"privacyLabel": "Приватность",
"privacy1": "Всё, что на экране,",
"privacy2": "остаётся",
"privacy3": "на вашем Mac.",
"privacyCopy": "Для эффекта нужно разрешение на запись экрана. Кадры обрабатываются в памяти через Metal, никуда не сохраняются и не отправляются. Сетевых запросов программа не делает вовсе.",
"noAccount": "Без аккаунта.",
"noAnalytics": "Без аналитики.",
"noAudio": "Без записи звука.",
"privacyLink": "Политика конфиденциальности",
"installLabel": "Установка",
"installTitle": "Три шага.<br> Около минуты.",
"installLink": "Подробная инструкция",
"install1": "Скачайте ZIP-архив из последнего выпуска на GitHub, распакуйте его и перетащите DUO Butterfly в папку «Программы».",
"install2": "Программа не нотаризована Apple, поэтому macOS заблокирует первый запуск. Откройте «Системные настройки» → «Конфиденциальность и безопасность» и нажмите «Все равно открыть».",
"install3": "Когда появится запрос, разрешите запись экрана. Доступ нужен только для встроенного дисплея, звук не записывается.",
"final1": "Попробуйте сами.",
"final2": "Это бесплатно.",
"free": "Бесплатно и с открытым кодом по лицензии MIT. Не понравится — просто перетащите в Корзину.",
"source": "Исходный код на GitHub",
"support": "Поддержка",
"gif": "Демо в GIF",
"license": "Лицензия",
"disclaimer": "Независимый проект, не связанный с Apple Inc. MacBook и macOS — товарные знаки Apple Inc.",
"sitePrivacy": "На сайте нет аналитики. Выбранный язык хранится только в вашем браузере. Хостинг — GitHub Pages.",
"navLabel": "Основная навигация",
"styleLabel": "Стиль эффекта",
"videoAlt": "Рендер DUO Butterfly: демонстрационный рабочий стол изгибается, размывается и темнеет, затем возвращается в обычный вид.",
"appAlt": "Окно программы DUO Butterfly"
},
es: {
"skip": "Ir al contenido",
"navStyles": "Estilos",
"navPrivacy": "Privacidad",
"navInstall": "Instalación",
"language": "Idioma",
"download": "Descarga gratis",
"downloadMac": "Descargar gratis",
"windowsSoon": "Próximamente para Windows.",
"title": "DUO Butterfly — El efecto al cerrar la tapa del MacBook",
"description": "Una app gratuita para MacBook. Al bajar la tapa, tu escritorio se curva, se desenfoca y se oscurece. Todo ocurre en tu Mac.",
"hero1": "Baja la tapa.",
"hero2": "Tu escritorio responde.",
"heroCopy": "DUO Butterfly es una app gratuita para la barra de menús del MacBook. Al bajar la tapa, el escritorio se curva, se desenfoca y se oscurece.<br> Vuelve a abrirla y todo estará tal como lo dejaste.",
"seeMotion": "Verlo en acción",
"requirements": "Gratis · macOS 26 o posterior · Apple silicon · Requiere sensor de ángulo de la tapa",
"motionLabel": "Cómo funciona",
"motion1": "La tapa se mueve.",
"motion2": "El efecto la acompaña.",
"motionCopy": "DUO Butterfly lee el sensor de ángulo integrado en tu MacBook. Cuanto más bajas la tapa, más intenso es el efecto. Si te detienes a medio camino, la imagen también se detiene.",
"demoCaption": "Renderizado real · Escritorio de muestra",
"play": "Ver demo",
"pause": "Pausa",
"mediaError": "No se ha podido reproducir el vídeo. Encontrarás la versión GIF al final de la página.",
"stylesLabel": "Tres estilos",
"styles1": "Un mismo gesto.",
"styles2": "Tres atmósferas.",
"silk": "Seda",
"dusk": "Crepúsculo",
"mist": "Niebla",
"silkCopy": "Una curva suave y un fundido delicado. El más sutil de los tres.",
"duskCopy": "Sombras más profundas. El escritorio se sumerge poco a poco en la oscuridad.",
"mistCopy": "Un desenfoque de cristal esmerilado que suaviza todo lo que hay en pantalla.",
"stylesNote": "En la app puedes ajustar por separado la curva, el desenfoque y la oscuridad.",
"controlLabel": "En la barra de menús",
"control1": "Todo lo que necesitas,",
"control2": "a un clic.",
"controlCopy": "Elige un estilo, pruébalo con un control deslizante y decide a partir de qué ángulo desaparece el efecto. También puedes activar un sonido al abrir la tapa o el inicio automático.",
"shortcutCopy": "Activa o desactiva el efecto desde cualquier app.",
"privacyLabel": "Privacidad",
"privacy1": "Tu pantalla",
"privacy2": "nunca sale",
"privacy3": "de tu Mac.",
"privacyCopy": "El efecto necesita permiso de grabación de pantalla. Los fotogramas se procesan en memoria con Metal y nunca se guardan ni se envían. La app no se conecta a internet.",
"noAccount": "Sin cuenta.",
"noAnalytics": "Sin analíticas.",
"noAudio": "Sin grabar audio.",
"privacyLink": "Lee la política de privacidad",
"installLabel": "Instalación",
"installTitle": "Tres pasos.<br> Un minuto.",
"installLink": "Guía de instalación detallada",
"install1": "Descarga el archivo ZIP de la última versión en GitHub, descomprímelo y arrastra DUO Butterfly a la carpeta Aplicaciones.",
"install2": "Apple no ha notarizado la app, así que macOS bloqueará la primera apertura. Ve a Ajustes del Sistema → Privacidad y seguridad y haz clic en Abrir igualmente.",
"install3": "Cuando se te pida, permite la grabación de pantalla. Solo se usa para la pantalla integrada y no se graba audio.",
"final1": "Compruébalo tú mismo.",
"final2": "Es gratis.",
"free": "Gratis y de código abierto con licencia MIT. ¿No te convence? Arrástrala a la Papelera y listo.",
"source": "Código fuente en GitHub",
"support": "Soporte",
"gif": "Demo en GIF",
"license": "Licencia",
"disclaimer": "Proyecto independiente, sin relación con Apple Inc. MacBook y macOS son marcas comerciales de Apple Inc.",
"sitePrivacy": "Este sitio no usa analíticas. El idioma elegido solo se guarda en tu navegador. Alojado en GitHub Pages.",
"navLabel": "Navegación principal",
"styleLabel": "Estilo del efecto",
"videoAlt": "DUO Butterfly aplicado a un escritorio de muestra: se curva, se desenfoca y se oscurece, y después vuelve a la normalidad.",
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
"title": "DUO Butterfly — MacBook 合盖桌面特效",
"description": "免费的 MacBook 菜单栏应用。合上屏幕盖时，桌面随之弯曲、模糊并逐渐变暗。全部在你的 Mac 上本地运行。",
"hero1": "合上 MacBook，",
"hero2": "桌面随之谢幕。",
"heroCopy": "DUO Butterfly 是一款免费的 MacBook 菜单栏应用。合上屏幕盖时，桌面会平滑地弯曲、模糊并逐渐变暗。<br>再次打开，一切如初。",
"seeMotion": "观看效果",
"requirements": "免费 · macOS 26 或更高版本 · Apple 芯片 · 需配备屏幕盖角度传感器",
"motionLabel": "工作原理",
"motion1": "屏幕盖动一分，",
"motion2": "效果跟一分。",
"motionCopy": "DUO Butterfly 读取 MacBook 内置的屏幕盖角度传感器。合得越低，效果越强；中途停下，画面也随之停住。",
"demoCaption": "应用实际渲染 · 示例桌面",
"play": "播放演示",
"pause": "暂停",
"mediaError": "视频无法播放。页面底部提供 GIF 版本。",
"stylesLabel": "三种风格",
"styles1": "同一个动作，",
"styles2": "三种氛围。",
"silk": "丝绸",
"dusk": "暮色",
"mist": "薄雾",
"silkCopy": "柔和弯曲，缓缓变暗。三种风格中最含蓄的一种。",
"duskCopy": "阴影更深，桌面慢慢沉入暗色之中。",
"mistCopy": "磨砂玻璃般的模糊，让屏幕上的一切变得柔和。",
"stylesNote": "弯曲、模糊和变暗程度均可在应用中分别调节。",
"controlLabel": "菜单栏应用",
"control1": "所需设置，",
"control2": "一点即达。",
"controlCopy": "选择风格，用滑块预览效果，并设定效果在哪个角度消失。还可以开启开盖提示音和登录时自动启动。",
"shortcutCopy": "在任何应用中都能开关效果。",
"privacyLabel": "隐私",
"privacy1": "屏幕画面",
"privacy2": "始终留在",
"privacy3": "你的 Mac 上。",
"privacyCopy": "实现效果需要屏幕录制权限。画面通过 Metal 在内存中处理，不会保存，也不会发送到任何地方。应用完全不联网。",
"noAccount": "无需账户。",
"noAnalytics": "无数据分析。",
"noAudio": "不录制声音。",
"privacyLink": "阅读隐私政策",
"installLabel": "安装",
"installTitle": "三个步骤，<br>一分钟搞定。",
"installLink": "详细安装指南",
"install1": "从 GitHub 最新版本下载 ZIP 文件，解压后将 DUO Butterfly 拖到“应用程序”文件夹。",
"install2": "应用未经 Apple 公证，因此 macOS 会阻止首次打开。请前往“系统设置”→“隐私与安全性”，点按“仍要打开”。",
"install3": "出现提示时，允许屏幕录制。该权限仅用于内置显示屏，不会录制声音。",
"final1": "亲自试试，",
"final2": "完全免费。",
"free": "免费开源，采用 MIT 许可证。不喜欢？直接拖到废纸篓即可。",
"source": "在 GitHub 查看源代码",
"support": "帮助与反馈",
"gif": "GIF 演示",
"license": "许可证",
"disclaimer": "独立项目，与 Apple Inc. 无关联。MacBook 和 macOS 是 Apple Inc. 的商标。",
"sitePrivacy": "本网站不使用数据分析。语言选择仅保存在你的浏览器中。由 GitHub Pages 托管。",
"navLabel": "主导航",
"styleLabel": "效果风格",
"videoAlt": "DUO Butterfly 实际渲染：示例桌面弯曲、模糊、变暗，然后恢复原状。",
"appAlt": "DUO Butterfly 应用窗口"
}
};
const nodes = [...document.querySelectorAll('[data-i18n]')];
translations.en = Object.fromEntries(nodes.map(node => [node.dataset.i18n, node.innerHTML]));
Object.assign(translations.en, {pause:"Pause",duskCopy:"Deeper shadows. Your desktop slowly sinks into darkness.",mistCopy:"A frosted-glass blur that softens everything on screen.",navLabel:"Main navigation",styleLabel:"Effect style",videoAlt:document.querySelector('#demo').getAttribute('aria-label'),appAlt:"DUO Butterfly app window",title:document.title,description:document.querySelector('meta[name="description"]').content});
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
