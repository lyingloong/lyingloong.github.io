// aHR0cHM6Ly9naXRodWIuY29tL2x1b3N0MjYvYWNhZGVtaWMtaG9tZXBhZ2U=
$(function () {
    var lazyLoadOptions = {
        scrollDirection: 'vertical',
        effect: 'fadeIn',
        effectTime: 300,
        placeholder: "",
        onError: function(element) {
            // Keep the page quiet if a lazy asset is unavailable.
        },
        afterLoad: function(element) {
            if (element.is('img')) {
                // remove background-image style
                element.css('background-image', 'none');
                element.css('min-height', '0');
            } else if (element.is('div')) {
                // set the style to background-size: cover;
                element.css('background-size', 'cover');
                element.css('background-position', 'center');
            }
        }
    };

    if ($.fn.Lazy) {
        $('img.lazy, div.lazy:not(.always-load)').Lazy($.extend({}, lazyLoadOptions, {visibleOnly: true}));
        $('div.lazy.always-load').Lazy($.extend({}, lazyLoadOptions, {visibleOnly: false}));
    }

    if ($.fn.tooltip) {
        $('[data-toggle="tooltip"]').tooltip();
    }

    var $grid = $('.grid');
    if ($grid.length && $.fn.masonry) {
        $grid.masonry({
            "percentPosition": true,
            "itemSelector": ".grid-item",
            "columnWidth": ".grid-sizer"
        });
        if ($.fn.imagesLoaded) {
            $grid.imagesLoaded().progress(function () {
                $grid.masonry('layout');
            });
        }
        $(".lazy").on("load", function () {
            $grid.masonry('layout');
        });
    }

    // Assemble mailto: on click so the address is not exposed as a plain link.
    document.querySelectorAll('.email-link').forEach(function (link) {
        var user = link.getAttribute('data-user');
        var domain = link.getAttribute('data-domain');
        if (!user || !domain) return;
        link.addEventListener('click', function (event) {
            event.preventDefault();
            window.location.href = 'mailto:' + user + '@' + domain;
        });
    });

    // Lightweight year navigation for pages with a sticky year sidebar.
    var yearNav = document.getElementById('navbar-year');
    if (yearNav) {
        var yearLinks = Array.prototype.slice.call(yearNav.querySelectorAll('a[href^="#"]'));
        var yearSections = yearLinks.map(function (link) {
            return document.querySelector(link.getAttribute('href'));
        }).filter(Boolean);

        var setActiveYear = function () {
            if (!yearSections.length) return;
            var activeSection = yearSections[0];
            yearSections.forEach(function (section) {
                if (section.getBoundingClientRect().top <= 120) {
                    activeSection = section;
                }
            });
            yearLinks.forEach(function (link) {
                link.classList.toggle('active', link.getAttribute('href') === '#' + activeSection.id);
            });
        };

        window.addEventListener('scroll', setActiveYear, { passive: true });
        window.addEventListener('resize', setActiveYear);
        setActiveYear();
    }
});
