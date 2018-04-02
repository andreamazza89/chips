import "phoenix_html"

const elmDiv = document.querySelector('#main-node');
import Elm from '../elm/compiled/main';

if (elmDiv) {
  Elm.Main.embed(elmDiv);
}
