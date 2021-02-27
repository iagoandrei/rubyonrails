// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
// require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import Tribute from "tributejs";
import $ from 'jquery';
import { Calendar } from '@fullcalendar/core';
import dayGrid from '@fullcalendar/daygrid';
import ptLocale from '@fullcalendar/core/locales/pt-br';

import Uppy from '@uppy/core';
import Dashboard from '@uppy/dashboard';
import XHRUpload from '@uppy/xhr-upload';
import Brazil_locale from 'uppy-locale-pt_BR';

global.Uppy = Uppy
global.XHRUpload = XHRUpload
global.Dashboard = Dashboard
global.Brazil_locale = Brazil_locale

global.Tribute = Tribute;
global.$ = $;
global.jQuery = $;
global.Calendar = Calendar;
global.dayGrid = dayGrid;
global.ptLocale = ptLocale;

require('jquery-mask-plugin');
require("jquery.auto-complete");
require('jquery-ui-bundle');
require('slick-carousel');
require('@chenfengyuan/datepicker');
require('datepicker.pt-BR.js');
require('jsgrid.js');
require('jsgrid-pt-br.js');
require('jquery-clone-fix.js');
require('@uppy/core/dist/style.css')
require('@uppy/dashboard/dist/style.css')

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
