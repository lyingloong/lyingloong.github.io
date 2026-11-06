(function () {
    'use strict';

    var content = document.getElementById('post-content');
    if (!content) return;

    var headings = Array.prototype.slice.call(content.querySelectorAll('h2, h3'));
    var toc = document.querySelector('.post-toc');
    var tocNav = toc && toc.querySelector('.post-toc-nav');
    if (tocNav && headings.length > 1) {
        var list = document.createElement('ol');
        var lastSection = null;
        headings.forEach(function (heading, index) {
            if (!heading.id) {
                var id = 'post-section-' + (index + 1);
                while (document.getElementById(id)) id += '-section';
                heading.id = id;
            }
            var item = document.createElement('li');
            var link = document.createElement('a');
            link.href = '#' + encodeURIComponent(heading.id);
            link.textContent = heading.textContent;
            item.appendChild(link);
            if (heading.tagName === 'H3' && lastSection) {
                var sublist = lastSection.querySelector('ol');
                if (!sublist) {
                    sublist = document.createElement('ol');
                    lastSection.appendChild(sublist);
                }
                sublist.appendChild(item);
            } else {
                list.appendChild(item);
                lastSection = item;
            }
        });
        tocNav.appendChild(list);
        toc.hidden = false;
    }

    // Keep wide Markdown tables inside the reading column, with keyboard access.
    var tables = Array.prototype.slice.call(content.querySelectorAll('table'));
    var wrappers = tables.map(function (table, index) {
        var wrapper = document.createElement('div');
        wrapper.className = 'post-table-wrap';
        wrapper.setAttribute('role', 'region');
        var caption = table.querySelector('caption');
        wrapper.setAttribute('aria-label', caption ? caption.textContent : 'Table ' + (index + 1));
        table.parentNode.insertBefore(wrapper, table);
        wrapper.appendChild(table);
        return wrapper;
    });
    var updateTableFocus = function () {
        wrappers.forEach(function (wrapper) {
            if (wrapper.scrollWidth > wrapper.clientWidth + 1) {
                wrapper.setAttribute('tabindex', '0');
            } else {
                wrapper.removeAttribute('tabindex');
            }
        });
    };
    updateTableFocus();
    window.addEventListener('resize', updateTableFocus, { passive: true });
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(updateTableFocus);
})();
