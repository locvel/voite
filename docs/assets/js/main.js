/**
 * Voite - Main JavaScript
 * Smooth interactions, animations, and haptic feedback
 */

// =========================================
// Intersection Observer for Scroll Animations
// =========================================

const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
            const delay = entry.target.dataset.delay || 0;
            setTimeout(() => {
                entry.target.classList.add('in-view');
            }, delay);
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe all elements with data-animate attribute
document.addEventListener('DOMContentLoaded', () => {
    const animatedElements = document.querySelectorAll('[data-animate]');
    animatedElements.forEach(el => observer.observe(el));
});

// =========================================
// Smooth Scroll with Haptic Feedback
// =========================================

document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        
        // Haptic feedback (if supported)
        if ('vibrate' in navigator) {
            navigator.vibrate(10);
        }
        
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            const navHeight = document.querySelector('.nav').offsetHeight;
            const targetPosition = target.offsetTop - navHeight;
            
            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });
        }
    });
});

// =========================================
// Navigation Scroll Effect
// =========================================

let lastScroll = 0;
const nav = document.querySelector('.nav');

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;
    
    // Add shadow on scroll
    if (currentScroll > 10) {
        nav.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.08)';
    } else {
        nav.style.boxShadow = 'none';
    }
    
    // Hide/show nav on scroll
    if (currentScroll > lastScroll && currentScroll > 500) {
        nav.style.transform = 'translateY(-100%)';
    } else {
        nav.style.transform = 'translateY(0)';
    }
    
    lastScroll = currentScroll;
}, { passive: true });

// =========================================
// Mobile Navigation Toggle
// =========================================

const navToggle = document.querySelector('.nav-toggle');
const navLinks = document.querySelector('.nav-links');

if (navToggle) {
    navToggle.addEventListener('click', () => {
        // Haptic feedback
        if ('vibrate' in navigator) {
            navigator.vibrate(10);
        }
        
        navToggle.classList.toggle('active');
        navLinks.classList.toggle('active');
        
        // Toggle animation
        const spans = navToggle.querySelectorAll('span');
        if (navToggle.classList.contains('active')) {
            spans[0].style.transform = 'rotate(45deg) translate(5px, 5px)';
            spans[1].style.opacity = '0';
            spans[2].style.transform = 'rotate(-45deg) translate(7px, -6px)';
        } else {
            spans[0].style.transform = 'none';
            spans[1].style.opacity = '1';
            spans[2].style.transform = 'none';
        }
    });
}

// =========================================
// Button Hover Effects with Haptic Feedback
// =========================================

document.querySelectorAll('.btn').forEach(button => {
    button.addEventListener('mouseenter', () => {
        button.style.transform = 'translateY(-2px)';
    });
    
    button.addEventListener('mouseleave', () => {
        button.style.transform = 'translateY(0)';
    });
    
    button.addEventListener('click', () => {
        // Haptic feedback
        if ('vibrate' in navigator) {
            navigator.vibrate(15);
        }
        
        // Ripple effect
        const ripple = document.createElement('span');
        ripple.style.position = 'absolute';
        ripple.style.borderRadius = '50%';
        ripple.style.background = 'rgba(255, 255, 255, 0.5)';
        ripple.style.width = '100px';
        ripple.style.height = '100px';
        ripple.style.marginTop = '-50px';
        ripple.style.marginLeft = '-50px';
        ripple.style.animation = 'ripple 0.6s';
        ripple.style.pointerEvents = 'none';
        
        const rect = button.getBoundingClientRect();
        ripple.style.left = event.clientX - rect.left + 'px';
        ripple.style.top = event.clientY - rect.top + 'px';
        
        button.style.position = 'relative';
        button.style.overflow = 'hidden';
        button.appendChild(ripple);
        
        setTimeout(() => ripple.remove(), 600);
    });
});

// Ripple animation
const style = document.createElement('style');
style.textContent = `
    @keyframes ripple {
        from {
            transform: scale(0);
            opacity: 1;
        }
        to {
            transform: scale(4);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// =========================================
// Parallax Effect on Hero
// =========================================

const hero = document.querySelector('.hero');
const phoneMockup = document.querySelector('.phone-mockup');
const floatingCards = document.querySelectorAll('.floating-card');

window.addEventListener('scroll', () => {
    if (!hero || !phoneMockup) return;
    
    const scrolled = window.pageYOffset;
    const heroHeight = hero.offsetHeight;
    
    if (scrolled < heroHeight) {
        // Parallax phone
        phoneMockup.style.transform = `translateY(${scrolled * 0.3}px)`;
        
        // Parallax floating cards
        floatingCards.forEach((card, index) => {
            const speed = 0.2 + (index * 0.1);
            card.style.transform = `translateY(${scrolled * speed}px)`;
        });
    }
}, { passive: true });

// =========================================
// Download Button Analytics (Privacy-friendly)
// =========================================

document.querySelectorAll('a[href*="download"], a[href*="releases"]').forEach(link => {
    link.addEventListener('click', () => {
        // Log to console (no external analytics)
        console.log('Download initiated:', link.href);
        
        // Strong haptic feedback for important action
        if ('vibrate' in navigator) {
            navigator.vibrate([20, 10, 20]);
        }
    });
});

// =========================================
// Feature Card Tilt Effect (Desktop)
// =========================================

if (window.matchMedia('(hover: hover)').matches) {
    document.querySelectorAll('.feature-card').forEach(card => {
        card.addEventListener('mousemove', (e) => {
            const rect = card.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            const centerX = rect.width / 2;
            const centerY = rect.height / 2;
            
            const rotateX = (y - centerY) / 20;
            const rotateY = (centerX - x) / 20;
            
            card.style.transform = `
                perspective(1000px)
                rotateX(${rotateX}deg)
                rotateY(${rotateY}deg)
                translateY(-4px)
                scale3d(1.02, 1.02, 1.02)
            `;
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.transform = '';
        });
    });
}

// =========================================
// Dynamic Stats Counter
// =========================================

function animateValue(element, start, end, duration) {
    if (!element) return;
    
    const range = end - start;
    const increment = end > start ? 1 : -1;
    const stepTime = Math.abs(Math.floor(duration / range));
    let current = start;
    
    const timer = setInterval(() => {
        current += increment;
        element.textContent = current + (element.dataset.suffix || '');
        
        if (current === end) {
            clearInterval(timer);
        }
    }, stepTime);
}

// Animate stats when they come into view
const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const valueElements = entry.target.querySelectorAll('.stat-value');
            valueElements.forEach(el => {
                const target = parseInt(el.textContent);
                if (!isNaN(target)) {
                    el.textContent = '0';
                    el.dataset.suffix = el.textContent.replace(/\d/g, '');
                    animateValue(el, 0, target, 2000);
                }
            });
            statsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

const heroStats = document.querySelector('.hero-stats');
if (heroStats) {
    statsObserver.observe(heroStats);
}

// =========================================
// Lazy Load Images
// =========================================

if ('IntersectionObserver' in window) {
    const imageObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                if (img.dataset.src) {
                    img.src = img.dataset.src;
                    img.removeAttribute('data-src');
                    imageObserver.unobserve(img);
                }
            }
        });
    });
    
    document.querySelectorAll('img[data-src]').forEach(img => {
        imageObserver.observe(img);
    });
}

// =========================================
// Prefers Reduced Motion
// =========================================

const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

if (prefersReducedMotion) {
    // Disable all animations
    document.querySelectorAll('[data-animate]').forEach(el => {
        el.style.animation = 'none';
        el.style.transition = 'none';
    });
}

// =========================================
// Service Worker Registration (for PWA)
// =========================================

if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        // Commented out - uncomment when service worker is ready
        // navigator.serviceWorker.register('/sw.js')
        //     .then(reg => console.log('Service Worker registered'))
        //     .catch(err => console.log('Service Worker registration failed'));
    });
}

// =========================================
// Theme Detection (Light/Dark Mode)
// =========================================

const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');

function updateTheme(e) {
    // Prepare for future dark mode support
    if (e.matches) {
        document.body.classList.add('dark-mode');
    } else {
        document.body.classList.remove('dark-mode');
    }
}

prefersDark.addEventListener('change', updateTheme);

// =========================================
// Copy to Clipboard with Feedback
// =========================================

document.querySelectorAll('[data-copy]').forEach(button => {
    button.addEventListener('click', async () => {
        const text = button.dataset.copy;
        
        try {
            await navigator.clipboard.writeText(text);
            
            // Haptic feedback
            if ('vibrate' in navigator) {
                navigator.vibrate(10);
            }
            
            // Visual feedback
            const originalText = button.textContent;
            button.textContent = 'Copied!';
            button.style.background = 'var(--color-success)';
            
            setTimeout(() => {
                button.textContent = originalText;
                button.style.background = '';
            }, 2000);
        } catch (err) {
            console.error('Failed to copy:', err);
        }
    });
});

// =========================================
// Performance Monitoring
// =========================================

if ('PerformanceObserver' in window) {
    // Monitor page load performance
    const perfObserver = new PerformanceObserver((list) => {
        list.getEntries().forEach(entry => {
            console.log('Performance:', entry.name, entry.duration + 'ms');
        });
    });
    
    perfObserver.observe({ entryTypes: ['navigation', 'paint'] });
}

// =========================================
// Initialize Everything
// =========================================

console.log('%cVoite', 'font-size: 48px; font-weight: bold; color: #E87722;');
console.log('%cYour voice, kept close.', 'font-size: 16px; color: #86868B;');
console.log('Built with privacy and design in mind. Check out our source: https://github.com/locvel/voite');
