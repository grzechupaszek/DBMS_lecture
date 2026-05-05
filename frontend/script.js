const menuEl     = document.getElementById("menu");
const titleEl    = document.getElementById("result-title");
const sqlEl      = document.getElementById("result-sql");
const metaEl     = document.getElementById("result-meta");
const tableEl    = document.getElementById("result-table");
const errorEl    = document.getElementById("result-error");
const resetBtn   = document.getElementById("reset-btn");

const resultView    = document.getElementById("result");
const formView      = document.getElementById("movie-form-view");
const addMovieBtn   = document.getElementById("add-movie-btn");

const movieForm     = document.getElementById("movie-form");
const genreSelect   = document.getElementById("genre-select");
const genreNewInput = document.getElementById("genre-new");
const companyList   = document.getElementById("company-list");
const directorsList = document.getElementById("directors-list");
const actorsList    = document.getElementById("actors-list");
const addDirectorBtn= document.getElementById("add-director-btn");
const addActorBtn   = document.getElementById("add-actor-btn");
const formCancelBtn = document.getElementById("form-cancel");
const formStatus    = document.getElementById("form-status");

const directorTpl = document.getElementById("director-row-template");
const actorTpl    = document.getElementById("actor-row-template");

// --------------------------------------------------------------------------
// Query browser (existing functionality)
// --------------------------------------------------------------------------
function clearResult() {
  sqlEl.textContent = "";
  metaEl.textContent = "";
  tableEl.innerHTML = "";
  errorEl.textContent = "";
}

function renderTable(columns, rows) {
  if (!rows.length) {
    tableEl.innerHTML = "<p><em>No rows returned.</em></p>";
    return;
  }
  const thead = "<thead><tr>" + columns.map(c => `<th>${c}</th>`).join("") + "</tr></thead>";
  const tbody = "<tbody>" + rows.map(r =>
    "<tr>" + columns.map(c => `<td>${r[c] === null ? "<em>null</em>" : String(r[c])}</td>`).join("") + "</tr>"
  ).join("") + "</tbody>";
  tableEl.innerHTML = `<table>${thead}${tbody}</table>`;
}

async function runQuery(id, kind, btn) {
  showResultView();
  clearResult();
  document.querySelectorAll("#menu button").forEach(b => b.classList.remove("active"));
  btn.classList.add("active");

  const url = kind === "modify" ? `/api/modify/${id}` : `/api/query/${id}`;
  const opts = kind === "modify" ? { method: "POST" } : {};

  try {
    const resp = await fetch(url, opts);
    const data = await resp.json();
    if (!resp.ok) {
      titleEl.textContent = `Error (${id})`;
      sqlEl.textContent = data.sql || "";
      errorEl.textContent = data.error || JSON.stringify(data);
      return;
    }
    titleEl.textContent = `${id} — ${data.title}`;
    sqlEl.textContent = data.sql;
    if (kind === "modify") {
      const p = data.params && data.params.length ? ` params=${JSON.stringify(data.params)}` : "";
      metaEl.textContent = `Rows affected: ${data.rows_affected}.${p}`;
    } else {
      metaEl.textContent = `Returned ${data.rows.length} row(s).`;
      renderTable(data.columns, data.rows);
    }
  } catch (err) {
    errorEl.textContent = err.toString();
  }
}

async function loadMenu() {
  const resp = await fetch("/api/queries");
  const cats = await resp.json();
  menuEl.innerHTML = "";
  for (const [cat, items] of Object.entries(cats)) {
    const h = document.createElement("h3");
    h.textContent = cat;
    menuEl.appendChild(h);
    for (const item of items) {
      const btn = document.createElement("button");
      btn.textContent = `${item.id}. ${item.title}`;
      if (item.kind === "modify") btn.classList.add("modify");
      btn.addEventListener("click", () => runQuery(item.id, item.kind, btn));
      menuEl.appendChild(btn);
    }
  }
}

resetBtn.addEventListener("click", async () => {
  if (!confirm("Drop the database and reload the seed data?")) return;
  const resp = await fetch("/api/reset", { method: "POST" });
  const data = await resp.json();
  showResultView();
  clearResult();
  titleEl.textContent = "Database reset";
  metaEl.textContent = `Recreated ${data.db}.`;
  // refresh cached lookups so new genres/companies show up after reset
  loadGenres();
  loadCompanies();
});

// --------------------------------------------------------------------------
// Input form for movie database
// --------------------------------------------------------------------------
function showResultView() {
  resultView.hidden = false;
  formView.hidden = true;
  addMovieBtn.classList.remove("active");
}

function showFormView() {
  resultView.hidden = true;
  formView.hidden = false;
  addMovieBtn.classList.add("active");
  document.querySelectorAll("#menu button").forEach(b => b.classList.remove("active"));
  // Ensure at least one director/actor row is visible.
  if (!directorsList.children.length) addDirectorRow();
  if (!actorsList.children.length)    addActorRow();
}

addMovieBtn.addEventListener("click", () => {
  if (formView.hidden) showFormView();
  else                 showResultView();
});

async function loadGenres() {
  try {
    const resp = await fetch("/api/genres");
    const items = await resp.json();
    genreSelect.innerHTML = '<option value="">-- choose a genre --</option>';
    for (const g of items) {
      const opt = document.createElement("option");
      opt.value = g.genre_id;
      opt.textContent = g.name;
      genreSelect.appendChild(opt);
    }
  } catch (e) { /* non-fatal */ }
}

async function loadCompanies() {
  try {
    const resp = await fetch("/api/companies");
    const items = await resp.json();
    companyList.innerHTML = "";
    for (const c of items) {
      const opt = document.createElement("option");
      opt.value = c.name;
      companyList.appendChild(opt);
    }
  } catch (e) { /* non-fatal */ }
}

function addDirectorRow() {
  const node = directorTpl.content.firstElementChild.cloneNode(true);
  const isActorChk = node.querySelector(".d-is-actor");
  const roleWrap   = node.querySelector(".d-actor-role-wrap");
  isActorChk.addEventListener("change", () => {
    roleWrap.hidden = !isActorChk.checked;
  });
  node.querySelector(".remove-row").addEventListener("click", () => node.remove());
  directorsList.appendChild(node);
}

function addActorRow() {
  const node = actorTpl.content.firstElementChild.cloneNode(true);
  node.querySelector(".remove-row").addEventListener("click", () => node.remove());
  actorsList.appendChild(node);
}

addDirectorBtn.addEventListener("click", addDirectorRow);
addActorBtn.addEventListener("click", addActorRow);
formCancelBtn.addEventListener("click", () => {
  showResultView();
});

function collectDirectors() {
  return [...directorsList.querySelectorAll(".director-row")].map(row => ({
    name:       row.querySelector(".d-name").value.trim(),
    dob:        row.querySelector(".d-dob").value || null,
    is_actor:   row.querySelector(".d-is-actor").checked,
    actor_role: row.querySelector(".d-actor-role")?.value.trim() || "",
  })).filter(d => d.name);
}

function collectActors() {
  return [...actorsList.querySelectorAll(".actor-row")].map(row => ({
    name: row.querySelector(".a-name").value.trim(),
    dob:  row.querySelector(".a-dob").value || null,
    role: row.querySelector(".a-role").value.trim(),
  })).filter(a => a.name);
}

function setStatus(msg, kind) {
  formStatus.textContent = msg;
  formStatus.className = kind || "";
}

movieForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  setStatus("");

  const fd = new FormData();
  fd.set("title",      movieForm.title.value.trim());
  fd.set("year",       movieForm.year.value);
  fd.set("length_min", movieForm.length_min.value);
  fd.set("company",    movieForm.company.value.trim());

  const genres = [];
  if (genreSelect.value)        genres.push(genreSelect.value);
  if (genreNewInput.value.trim()) genres.push(genreNewInput.value.trim());
  fd.set("genres",    JSON.stringify(genres));
  fd.set("directors", JSON.stringify(collectDirectors()));
  fd.set("actors",    JSON.stringify(collectActors()));

  const pdf = movieForm.plot_pdf.files[0];
  if (pdf) fd.append("plot_pdf", pdf);

  setStatus("Saving…");
  try {
    const resp = await fetch("/api/movies", { method: "POST", body: fd });
    const data = await resp.json();
    if (!resp.ok) {
      setStatus(`Error: ${data.error || JSON.stringify(data)}`, "err");
      return;
    }
    setStatus(`Saved! Movie ID #${data.movie_id} — "${data.title}" (${data.year}).`, "ok");
    movieForm.reset();
    directorsList.innerHTML = "";
    actorsList.innerHTML = "";
    addDirectorRow();
    addActorRow();
    // Pick up newly created genre/company in the lookups.
    loadGenres();
    loadCompanies();
  } catch (err) {
    setStatus(err.toString(), "err");
  }
});

// --------------------------------------------------------------------------
// Init
// --------------------------------------------------------------------------
loadMenu();
loadGenres();
loadCompanies();
