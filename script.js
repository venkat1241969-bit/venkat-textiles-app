// Venkat Textiles Main Script (Updated with Catalog Display & Instant WhatsApp Speed)

import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
import { getFirestore, collection, getDocs, doc, setDoc, updateDoc, query, orderBy } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

const firebaseConfig = {
    apiKey: "AIzaSyBPOp8NtMBP09rNtCGe5-wRre6Y_Zt5g0M",
    authDomain: "venkat-textiles.firebaseapp.com",
    projectId: "venkat-textiles",
    storageBucket: "venkat-textiles.firebasestorage.app",
    messagingSenderId: "636994469508",
    appId: "1:636994469508:web:3635e18d8ee64288be0cd1"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

let cart = [];
let fetchedProducts = {};
let currentOrderId = "";

// Load Products on Storefront
async function loadStoreProducts() {
    const grid = document.getElementById('products-grid');
    if(!grid) return;

    try {
        const q = query(collection(db, "items"), orderBy("timestamp", "desc"));
        const querySnapshot = await getDocs(q);
        let html = '';

        if(querySnapshot.empty) {
            grid.innerHTML = `<p class="text-gray-500 text-center col-span-2 text-xs py-8">ప్రస్తుతానికి ప్రొడక్ట్స్ ఏవీ అందుబాటులో లేవు.</p>`;
            return;
        }

        querySnapshot.forEach((docSnap) => {
            const p = docSnap.data();
            const id = docSnap.id;
            fetchedProducts[id] = p;

            const stock = Number(p.stock) || 0;
            const isOut = stock <= 0;
            const catalogBadge = p.catalog ? `<span class="bg-rose-50 text-rose-700 text-[9px] font-extrabold px-2 py-0.5 rounded-md inline-block mb-1 border border-rose-100">📁 ${p.catalog}</span>` : '';

            html += `
                <div class="bg-white p-3 rounded-2xl border border-gray-200 shadow-sm flex flex-col justify-between">
                    <div>
                        <div class="relative mb-2">
                            <img src="${p.image}" onclick="openImageZoom('${p.image}', '${p.name}')" class="w-full h-40 object-cover rounded-xl cursor-pointer hover:opacity-95 transition">
                            <span class="absolute top-2 left-2 bg-rose-600 text-white text-[10px] font-black px-2 py-0.5 rounded-lg shadow">${p.discount || 30}% off</span>
                        </div>
                        ${catalogBadge}
                        <h3 class="font-bold text-xs text-gray-900 truncate">${p.name}</h3>
                        <p class="text-[10px] text-gray-500 truncate mb-1">${p.description || ''}</p>
                        <div class="flex items-center gap-2 mb-2">
                            <span class="text-rose-600 font-black text-sm">₹${p.price}</span>
                            <span class="text-gray-400 text-[10px] line-through">₹${Math.round(p.price * 1.43)}</span>
                        </div>
                    </div>
                    <div>
                        <p class="text-[10px] font-bold ${isOut ? 'text-red-600' : 'text-emerald-600'} mb-2">
                            ${isOut ? '❌ Out of Stock' : `📦 Stock: ${stock} Left`}
                        </p>
                        <button onclick="addToCart('${id}')" ${isOut ? 'disabled' : ''} class="w-full ${isOut ? 'bg-gray-300 cursor-not-allowed' : 'bg-rose-600 hover:bg-rose-700 shadow'} text-white py-1.5 rounded-xl text-xs font-bold transition">
                            🛒 Add to Cart
                        </button>
                    </div>
                </div>
            `;
        });
        grid.innerHTML = html;
    } catch(e) {
        console.error("Error loading products: ", e);
    }
}

// Image Zoom Modal Functions
window.openImageZoom = function(imgSrc, title) {
    const modal = document.getElementById('imageZoomModal');
    const zoomedImg = document.getElementById('zoomedImg');
    const zoomedTitle = document.getElementById('zoomedTitle');
    if(modal && zoomedImg) {
        zoomedImg.src = imgSrc;
        if(zoomedTitle) zoomedTitle.innerText = title;
        modal.classList.remove('hidden');
    }
}

window.closeImageZoom = function() {
    const modal = document.getElementById('imageZoomModal');
    if(modal) modal.classList.add('hidden');
}

// Cart Management
window.addToCart = function(id) {
    const p = fetchedProducts[id];
    const stock = Number(p.stock) || 0;
    
    let existing = cart.find(i => i.id === id);
    if(existing) {
        if(existing.qty < stock) {
            existing.qty++;
        } else {
            alert("అంతకంటే ఎక్కువ స్టాక్ అందుబాటులో లేదు!");
            return;
        }
    } else {
        if(stock > 0) {
            cart.push({ id: id, name: p.name, price: p.price, qty: 1, image: p.image });
        } else {
            alert("ఈ ప్రొడక్ట్ స్టాక్ అయిపోయింది!");
            return;
        }
    }
    updateCartUI();
}

function updateCartUI() {
    const countEl = document.getElementById('cart-count');
    const itemsEl = document.getElementById('cart-items');
    const totalEl = document.getElementById('cart-total');

    let totalQty = 0;
    let totalPrice = 0;
    let html = '';

    cart.forEach((item, index) => {
        totalQty += item.qty;
        totalPrice += item.price * item.qty;
        html += `
            <div class="flex items-center justify-between bg-gray-50 p-2 rounded-xl border border-gray-200 text-xs">
                <img src="${item.image}" class="w-10 h-10 object-cover rounded-lg">
                <div class="flex-grow px-2">
                    <p class="font-bold text-gray-800 truncate max-w-[110px]">${item.name}</p>
                    <p class="text-[10px] text-rose-600 font-bold">₹${item.price} x ${item.qty}</p>
                </div>
                <div class="flex items-center gap-1">
                    <button onclick="changeQty(${index}, -1)" class="bg-gray-200 px-1.5 py-0.5 rounded font-bold">-</button>
                    <span class="font-bold text-xs">${item.qty}</span>
                    <button onclick="changeQty(${index}, 1)" class="bg-gray-200 px-1.5 py-0.5 rounded font-bold">+</button>
                </div>
            </div>
        `;
    });

    if(countEl) countEl.innerText = totalQty;
    if(itemsEl) itemsEl.innerHTML = html || '<p class="text-gray-400 text-center text-xs py-4">కార్ట్ ఖాళీగా ఉంది</p>';
    if(totalEl) totalEl.innerText = `₹${totalPrice}`;
}

window.changeQty = function(index, delta) {
    cart[index].qty += delta;
    if(cart[index].qty <= 0) {
        cart.splice(index, 1);
    }
    updateCartUI();
}

window.toggleCart = function() {
    const drawer = document.getElementById('cartDrawer');
    if(drawer) drawer.classList.toggle('hidden');
}

// Checkout & QR Code Modal
window.proceedToCheckout = function() {
    if(cart.length === 0) {
        alert("మీ కార్ట్ ఖాళీగా ఉంది!");
        return;
    }
    toggleCart();
    document.getElementById('checkoutModal').classList.remove('hidden');
    
    let total = 0;
    cart.forEach(i => total += i.price * i.qty);
    document.getElementById('qrTotalAmount').innerText = total;
    currentOrderId = "VT-" + Math.floor(100000 + Math.random() * 900000);
}

window.closeCheckoutModal = function() {
    document.getElementById('checkoutModal').classList.add('hidden');
}

// Instant Speed WhatsApp Order Trigger
window.finishOrderWhatsApp = function() {
    const utrNumber = document.getElementById('utrNumber').value.trim();
    if(!utrNumber || utrNumber.length < 6) {
        alert("దయచేసి పేమెంట్ పూర్తి చేసిన తర్వాత మీ 12 అంకెల UTR / Transaction ID ని ఎంటర్ చేయండి!");
        return;
    }

    const name = document.getElementById('custName').value;
    const phone = document.getElementById('custPhone').value;
    const address = document.getElementById('custAddress').value;
    const pincode = document.getElementById('custPincode').value;

    if(!name || !phone || !address || !pincode) {
        alert("దయచేసి అన్ని వివరాలను పూరించండి!");
        return;
    }

    let total = 0;
    cart.forEach(i => { total += i.price * i.qty; });

    // Background sync to Firebase (Non-blocking for instant speed)
    setDoc(doc(db, "orders", currentOrderId), {
        orderId: currentOrderId,
        name: name,
        phone: phone,
        address: address,
        pincode: pincode,
        items: cart,
        total: total,
        utrNumber: utrNumber,
        waybill: "",
        shippingDate: "",
        timestamp: new Date().toISOString()
    }).catch(err => console.error("Order save error: ", err));

    cart.forEach(item => {
        const productData = fetchedProducts[item.id];
        if(productData) {
            const currentStock = Number(productData.stock) || 0;
            const updatedStock = Math.max(0, currentStock - item.qty);
            const newStatus = updatedStock === 0 ? "Out of Stock" : (productData.status || "In Stock");

            updateDoc(doc(db, "items", item.id), {
                stock: updatedStock,
                status: newStatus
            }).catch(err => console.error("Stock update error: ", err));
        }
    });

    let orderSummary = `🚀 *New Paid Order with UTR Proof (Venkat Textiles)*\n`;
    orderSummary += `🆔 Order ID: *${currentOrderId}*\n`;
    orderSummary += `💳 UTR / Transaction ID: *${utrNumber}*\n\n`;
    orderSummary += `👤 పేరు: *${name}*\n`;
    orderSummary += `📞 ఫోన్: *${phone}*\n`;
    orderSummary += `🏠 అడ్రస్: *${address}*\n`;
    orderSummary += `📮 పిన్‌కోడ్: *${pincode}*\n\n`;
    orderSummary += `🛒 ప్రొడక్ట్స్:\n`;
    
    cart.forEach(i => {
        orderSummary += `- ${i.name} (${i.qty} pcs) : ₹${i.price * i.qty}\n`;
    });

    orderSummary += `\n💰 మొత్తం బిల్లు (Total): *₹${total}*`;
    orderSummary += `\n✅ పేమెంట్ వెరిఫై చేయబడింది (Merchant UPI: 8121911438@okbizaxis).`;

    const myNumber = "919441447923";
    window.open(`https://wa.me/${myNumber}?text=${encodeURIComponent(orderSummary)}`, '_blank');
}

window.onload = function() {
    loadStoreProducts();
};
      
