(() => {
const notes = [{"id":"688fb137","title":"Architectural equivariance versus objective invariance","url":"/symo-forest/notes/688fb137/","tags":["symmetry"],"aliases":["symmetry breakers","incompatible regularizers"]},
{"id":"93e6cfab","title":"Block functional calculus and the four-step round trip","url":"/symo-forest/notes/93e6cfab/","tags":["algebra","scale"],"aliases":["functional calculus","exact block function","isomorphism argument","four-step-round-trip"]},
{"id":"0c051391","title":"Canonical test vectors and the pairing theorem","url":"/symo-forest/notes/0c051391/","tags":["algebra","scale"],"aliases":["probing","test vectors","pairing theorem","one-probe-per-copy"]},
{"id":"edc05432","title":"Compiling diagram terms into einsum contractions and Kronecker ties","url":"/symo-forest/notes/edc05432/","tags":["implementation","scale"],"aliases":["einsum compilation","tie_left_axes","compile_apply_term","estimation-cost"]},
{"id":"a97e31ca","title":"Crossing symmetry groups in an MLP-step recurrent network","url":"/symo-forest/notes/a97e31ca/","tags":["recurrence"],"aliases":["RNN symmetry specification","G_h and G_z","two groups","local versus global symmetry"]},
{"id":"dc31c6c2","title":"Declarative symmetry specifications on parameter trees","url":"/symo-forest/notes/dc31c6c2/","tags":["implementation"],"aliases":["Symo.Make","model declaration","ptree","declare-your-symmetries"]},
{"id":"c3f2936b","title":"Diagonal and cross-leaf tiles in the multi-leaf commutant","url":"/symo-forest/notes/c3f2936b/","tags":["recurrence","algebra"],"aliases":["mosaic","tiles","RNN curvature figure","four patterns","bias pattern","cross tiles"]},
{"id":"7ee7cea7","title":"Explicit canonical test vectors for k = 1 and k = 2","url":"/symo-forest/notes/7ee7cea7/","tags":["algebra","scale"],"aliases":["Helmert vector","z_parallel","z_perp","two test vectors","seven test vectors"]},
{"id":"790ac25a","title":"Factor coordinates are width-dependent; Wedderburn blocks are width-independent","url":"/symo-forest/notes/790ac25a/","tags":["algebra","scale"],"aliases":["factors versus blocks","size-dependent encoding","blocks not surrogates","function-of-coordinates-trap"]},
{"id":"593dad00","title":"Finite and continuous weight-space symmetry groups","url":"/symo-forest/notes/593dad00/","tags":["symmetry"],"aliases":["list of symmetries","symmetry examples"]},
{"id":"273c28e5","title":"First and second moments of a random permutation matrix","url":"/symo-forest/notes/273c28e5/","tags":["algebra"],"aliases":["second order permutation average","E[P⊗P]","permutation moments"]},
{"id":"6b12a533","title":"Function invariance implies gradient equivariance","url":"/symo-forest/notes/6b12a533/","tags":["symmetry"],"aliases":["equivariance","gradient symmetry","orbit level set"]},
{"id":"8f5747b6","title":"Gallery of orbit-average figures","url":"/symo-forest/notes/8f5747b6/","tags":["meta"],"aliases":["figure gallery","gallery","visuals"]},
{"id":"b2ecabc3","title":"Hidden-unit permutations act by Kronecker products on parameter tensors","url":"/symo-forest/notes/b2ecabc3/","tags":["symmetry"],"aliases":["unit permutation","hidden unit symmetry","permutation symmetry"]},
{"id":"33d479c5","title":"Index invariance and the equality-pattern basis","url":"/symo-forest/notes/33d479c5/","tags":["algebra"],"aliases":["delta/1 structure","same or different","invariance constraint"]},
{"id":"35cc480f","title":"Isotypic decomposition of V^⊗k under the symmetric group","url":"/symo-forest/notes/35cc480f/","tags":["algebra"],"aliases":["isotypic kinds","15 decomposition","multiplicity blocks","Fifteen = 2² + 3² + 1² + 1²"]},
{"id":"411ed5c1","title":"Module correspondence and algebraic verification in symo","url":"/symo-forest/notes/411ed5c1/","tags":["implementation"],"aliases":["module layout","library structure","test-suite-shape","symo-design-notes"]},
{"id":"d8c20588","title":"Multi-leaf parameter trees and recurrent mosaics — trailhead","url":"/symo-forest/notes/d8c20588/","tags":["meta","recurrence"],"aliases":["recurrence trailhead","RNN trailhead"]},
{"id":"54900ffe","title":"Orbit averages and the commutant algebra — map of the vault","url":"/symo-forest/notes/54900ffe/","tags":["meta"],"aliases":["forest map","orbit averaging overview","start here"]},
{"id":"588b9727","title":"Orthogonal representations on parameter trees","url":"/symo-forest/notes/588b9727/","tags":["symmetry"],"aliases":["orthogonality","A transpose A","orthogonal representation"]},
{"id":"a0bb3d95","title":"Partial partitions, diagram terms, and Bell numbers","url":"/symo-forest/notes/a0bb3d95/","tags":["algebra"],"aliases":["B4 = 15","set partitions","partition algebra","diagram basis"]},
{"id":"a575e53a","title":"Product kinds across multiple groups and block assembly over parameter trees","url":"/symo-forest/notes/a575e53a/","tags":["algebra"],"aliases":["global kinds","tree assembly","blocks_of_factors","multi-group kinds"]},
{"id":"e176661b","title":"Projecting outer products via compile-time Cholesky and einsums","url":"/symo-forest/notes/e176661b/","tags":["algebra","scale"],"aliases":["design matrix","Cholesky","triangular solve","estimator compilation"]},
{"id":"46af9ff5","title":"Schur's lemma and the Wedderburn decomposition of the commutant","url":"/symo-forest/notes/46af9ff5/","tags":["algebra"],"aliases":["Wedderburn decomposition","isotypic decomposition","Schur-Weyl","cost scales with multiplicity"]},
{"id":"b50cfe81","title":"Semisimplicity of the partition algebra and the stable range n ≥ 2k","url":"/symo-forest/notes/b50cfe81/","tags":["algebra"],"aliases":["stable range","n >= 2k","semisimple partition algebra"]},
{"id":"2addfd8f","title":"Signed permutations and the hyperoctahedral group","url":"/symo-forest/notes/2addfd8f/","tags":["symmetry","algebra"],"aliases":["signed permutations","sign symmetry","2^n n!","hyperoctahedral group"]},
{"id":"b81e35a1","title":"Symbolic Gram matrix via the partition lattice","url":"/symo-forest/notes/b81e35a1/","tags":["algebra"],"aliases":["Gram matrix","normal equations","non-orthogonal basis","partition join"]},
{"id":"4875a459","title":"Symmetric component bundling and the Λ²W ⊗ Λ²F completeness condition","url":"/symo-forest/notes/4875a459/","tags":["algebra"],"aliases":["symmetric basis","bundle transposes","symmetric_basis_is_complete"]},
{"id":"38beecad","title":"Test vectors, block functional calculus, and width transport — trailhead","url":"/symo-forest/notes/38beecad/","tags":["meta","scale","algebra"],"aliases":["scale trailhead","computation trailhead","transport trailhead"]},
{"id":"756b0592","title":"The commutant and partition algebra — trailhead","url":"/symo-forest/notes/756b0592/","tags":["meta","algebra"],"aliases":["algebra trailhead","invariant matrix algebra"]},
{"id":"f914d5ad","title":"The compile-time dictionary between factor coordinates and Wedderburn blocks","url":"/symo-forest/notes/f914d5ad/","tags":["algebra","scale"],"aliases":["dictionary table","P table","inner product probes","compile-time-dictionary"]},
{"id":"6226b6f2","title":"The first-order orbit average projects onto the invariant subspace","url":"/symo-forest/notes/6226b6f2/","tags":["symmetry","algebra"],"aliases":["first order average","R1","orbit centroid","uniform shadow"]},
{"id":"07ef8651","title":"The symo compiler and orbit architecture — trailhead","url":"/symo-forest/notes/07ef8651/","tags":["meta","implementation"],"aliases":["symo","implementation trailhead","OCaml"]},
{"id":"8eb163bd","title":"The twirl and second-order orbit average project onto the commutant","url":"/symo-forest/notes/8eb163bd/","tags":["symmetry","algebra"],"aliases":["second order average","R2","twirl","commutant projection"]},
{"id":"d47131ad","title":"The Π/Π⊥ projector basis and the row mean–covariance identity","url":"/symo-forest/notes/d47131ad/","tags":["algebra"],"aliases":["Pi basis","orthogonal blocks","parallel and perpendicular","mean plus covariance"]},
{"id":"be071dc0","title":"Transporting invariant operators across widths","url":"/symo-forest/notes/be071dc0/","tags":["algebra","scale"],"aliases":["transport","re-encoding at another size","spectrum preservation","factor-of-n bug"]},
{"id":"c35dde47","title":"Two-sided conjugation W ↦ QWQᵀ in recurrent networks","url":"/symo-forest/notes/c35dde47/","tags":["recurrence","algebra"],"aliases":["vanilla RNN","Q W Q transpose","square state matrix","15 pattern classes","GRU"]},
{"id":"e2dee3bd","title":"Wedderburn decomposition and isotypic blocks — trailhead","url":"/symo-forest/notes/e2dee3bd/","tags":["meta","algebra"],"aliases":["Wedderburn trailhead","isotypic blocks trailhead"]},
{"id":"9a072006","title":"Weight-space symmetries and orbit projections — trailhead","url":"/symo-forest/notes/9a072006/","tags":["meta","symmetry"],"aliases":["symmetry trailhead"]},
{"id":"3862bdb6","title":"Why evaluating fixed factor coordinates at a surrogate width changes the operator","url":"/symo-forest/notes/3862bdb6/","tags":["algebra","scale"],"aliases":["shrink warning","surrogate size","fixed factors at smaller n"]},
{"id":"57bf40fa","title":"Worked example: a 3×4 weight matrix under three symmetry groups","url":"/symo-forest/notes/57bf40fa/","tags":["algebra"],"aliases":["running example","3x4 example","the 12x12 operator"]}];
const $ = (id) => document.getElementById(id);
let active = 0;
const modal = $('search-modal'), input = $('search-input'), results = $('search-results');
if (!modal || !input || !results) return;
const hay = (n) => [n.title, n.id, ...(n.tags || []), ...(n.aliases || [])].join(' ').toLowerCase();
const score = (n, q) => { const h = hay(n); const t = n.title.toLowerCase(); if (t === q) return 100; if (t.startsWith(q)) return 80; if (h.includes(q)) return 40 - Math.min(20, h.indexOf(q)); return -1; };
function escapeHtml(s) { return s.replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }
function render() {
  const q = input.value.trim().toLowerCase();
  const matches = (q ? notes.map(n => [score(n, q), n]).filter(x => x[0] >= 0).sort((a,b) => b[0] - a[0] || a[1].title.localeCompare(b[1].title)).map(x => x[1]) : notes).slice(0, 12);
  active = Math.min(active, Math.max(0, matches.length - 1));
  results.innerHTML = matches.length ? matches.map((n, i) => `<li><a href="${n.url}" class="block px-4 py-3 no-underline text-gray-300 hover:bg-gray-800 transition-colors" ${i === active ? 'style="background:rgb(55 65 81)"' : ''}><span class="block text-gray-200 font-semibold">${escapeHtml(n.title)}</span><span class="block text-gray-500 text-xs mt-0.5">${escapeHtml(n.tags.map(t => '#' + t).join(' '))}</span></a></li>`).join('') : '<li class="text-gray-500 px-4 py-3">No matching notes</li>';
}
function openSearch() { modal.hidden = false; active = 0; input.value = ''; render(); setTimeout(() => input.focus(), 0); }
function closeSearch() { modal.hidden = true; }
const openBtn = $('search-open');
openBtn && openBtn.addEventListener('click', openSearch);
document.addEventListener('keydown', (e) => {
  if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') { e.preventDefault(); openSearch(); return; }
  if (modal.hidden) return;
  if (e.key === 'Escape') { e.preventDefault(); closeSearch(); }
  if (e.key === 'ArrowDown') { e.preventDefault(); active++; render(); }
  if (e.key === 'ArrowUp') { e.preventDefault(); active = Math.max(0, active - 1); render(); }
  if (e.key === 'Enter') { const links = results.querySelectorAll('a'); const a = links[active] || links[0]; if (a) a.click(); }
});
modal.addEventListener('click', (e) => { if (e.target === modal) closeSearch(); });
input.addEventListener('input', () => { active = 0; render(); });
const thm = document.getElementById('theme-toggle');
thm && thm.addEventListener('click', () => {
  const h = document.documentElement;
  const c = h.getAttribute('data-theme') || 'dark';
  const n = c === 'dark' ? 'light' : 'dark';
  h.setAttribute('data-theme', n);
  localStorage.setItem('eg-theme', n);
});
})();
