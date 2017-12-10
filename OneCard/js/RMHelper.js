function mover() {
    //去除相邻节点样式
    var object_nav = arguments[0].parentElement.parentElement;
    for (var i = 0; i < object_nav.children.length; ++i) {
        var object_cld = object_nav.children[i].children[0];
        object_cld.children[0].style.color = "#000";
        object_cld.className = null;

    }

    //当前节点添加样式
    arguments[0].className = "on";
    arguments[0].children[0].style.color = "#fff";
    arguments[0].children[0].style.cursor = "pointer";
}
function mout() {
    var cardname = $get('hidCardType').value
    var object = document.getElementById(cardname);
    mover(object);
} 