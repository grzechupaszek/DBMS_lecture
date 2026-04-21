const menuEl     = document.getElementById("menu");
const titleEl    = document.getElementById("result-title");
const sqlEl      = document.getElementById("result-sql");
const metaEl     = document.getElementById("result-meta");
const tableEl    = document.getElementById("result-table");
const errorEl    = document.getElementById("result-error");
const resetBtn   = document.getElementById("reset-btn");

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
  clearResult();
  titleEl.textContent = "Database reset";
  metaEl.textContent = `Recreated ${data.db}.`;
});

loadMenu();
