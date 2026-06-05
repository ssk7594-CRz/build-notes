const STORAGE_KEY = "build-notes-mvp-v2";

const statusLabels = {
  planned: "구현할 기능",
  review: "검토 중",
  doing: "진행 중",
  done: "구현됨",
  hold: "보류",
};

const priorityLabels = {
  high: "높음",
  medium: "보통",
  low: "낮음",
};

const defaultState = {
  selectedAppId: "app-1",
  searchQuery: "",
  apps: [
    {
      id: "app-1",
      name: "샘플 앱",
      repoUrl: "",
      features: [
        createFeatureSeed("배포 후 떠오른 기능을 빠르게 적는 인박스", "planned", "high", "v1.0", "생각나는 즉시 적는 흐름이 핵심."),
        createFeatureSeed("구현된 기능과 구현할 기능을 한눈에 구분", "done", "medium", "v1.0", ""),
        createFeatureSeed("GitHub 레포 연결 후 기능 후보 불러오기", "review", "medium", "v1.2", "README, issue, PR에서 후보를 가져오는 방향."),
      ],
    },
  ],
};

let state = normalizeState(loadState());

const els = {
  appForm: document.querySelector("#app-form"),
  appName: document.querySelector("#app-name"),
  appList: document.querySelector("#app-list"),
  currentAppName: document.querySelector("#current-app-name"),
  featureForm: document.querySelector("#feature-form"),
  featureTitle: document.querySelector("#feature-title"),
  featureVersion: document.querySelector("#feature-version"),
  featurePriority: document.querySelector("#feature-priority"),
  featureStatus: document.querySelector("#feature-status"),
  featureSearch: document.querySelector("#feature-search"),
  repoUrl: document.querySelector("#repo-url"),
  saveRepo: document.querySelector("#save-repo"),
  exportData: document.querySelector("#export-data"),
  importData: document.querySelector("#import-data"),
  importFile: document.querySelector("#import-file"),
  statTotal: document.querySelector("#stat-total"),
  statPlanned: document.querySelector("#stat-planned"),
  statDone: document.querySelector("#stat-done"),
  appButtonTemplate: document.querySelector("#app-button-template"),
  featureCardTemplate: document.querySelector("#feature-card-template"),
};

function createFeatureSeed(title, status, priority, targetVersion, note) {
  const now = Date.now();
  return {
    id: `feature-${crypto.randomUUID()}`,
    title,
    status,
    priority,
    targetVersion,
    note,
    createdAt: now,
    updatedAt: now,
  };
}

function loadState() {
  const stored = localStorage.getItem(STORAGE_KEY);
  if (!stored) return structuredClone(defaultState);

  try {
    return JSON.parse(stored);
  } catch {
    return structuredClone(defaultState);
  }
}

function normalizeState(rawState) {
  const fallback = structuredClone(defaultState);
  const apps = Array.isArray(rawState?.apps) && rawState.apps.length > 0 ? rawState.apps : fallback.apps;

  return {
    selectedAppId: rawState?.selectedAppId ?? apps[0].id,
    searchQuery: rawState?.searchQuery ?? "",
    apps: apps.map((app) => ({
      id: app.id ?? createId("app"),
      name: app.name ?? "이름 없는 앱",
      repoUrl: app.repoUrl ?? "",
      features: Array.isArray(app.features) ? app.features.map(normalizeFeature) : [],
    })),
  };
}

function normalizeFeature(feature) {
  const now = Date.now();
  return {
    id: feature.id ?? createId("feature"),
    title: feature.title ?? "이름 없는 기능",
    status: statusLabels[feature.status] ? feature.status : "planned",
    priority: priorityLabels[feature.priority] ? feature.priority : "medium",
    targetVersion: feature.targetVersion ?? "",
    note: feature.note ?? "",
    createdAt: feature.createdAt ?? now,
    updatedAt: feature.updatedAt ?? feature.createdAt ?? now,
  };
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function getCurrentApp() {
  return state.apps.find((app) => app.id === state.selectedAppId) ?? state.apps[0];
}

function createId(prefix) {
  return `${prefix}-${crypto.randomUUID()}`;
}

function touch(feature) {
  feature.updatedAt = Date.now();
}

function render() {
  const app = getCurrentApp();
  if (!app) return;

  state.selectedAppId = app.id;
  els.currentAppName.textContent = app.name;
  els.repoUrl.value = app.repoUrl ?? "";
  els.featureSearch.value = state.searchQuery;

  renderApps();
  renderStats(app);
  renderBoard(app);
  saveState();
}

function renderApps() {
  els.appList.replaceChildren();

  state.apps.forEach((app) => {
    const button = els.appButtonTemplate.content.firstElementChild.cloneNode(true);
    const total = app.features.length;
    const done = app.features.filter((feature) => feature.status === "done").length;

    button.classList.toggle("active", app.id === state.selectedAppId);
    button.querySelector(".app-initial").textContent = app.name.trim().charAt(0).toUpperCase();
    button.querySelector("strong").textContent = app.name;
    button.querySelector("small").textContent = `${done}/${total} 구현됨`;
    button.addEventListener("click", () => {
      state.selectedAppId = app.id;
      render();
    });

    els.appList.append(button);
  });
}

function renderStats(app) {
  const total = app.features.length;
  const planned = app.features.filter((feature) => feature.status === "planned").length;
  const done = app.features.filter((feature) => feature.status === "done").length;

  els.statTotal.textContent = total;
  els.statPlanned.textContent = planned;
  els.statDone.textContent = done;
}

function renderBoard(app) {
  Object.keys(statusLabels).forEach((status) => {
    const list = document.querySelector(`#${status}-list`);
    const count = document.querySelector(`#count-${status}`);
    const features = getVisibleFeatures(app).filter((feature) => feature.status === status);

    count.textContent = features.length;
    list.replaceChildren();

    if (features.length === 0) {
      const empty = document.createElement("div");
      empty.className = "empty-state";
      empty.textContent = `${statusLabels[status]} 없음`;
      list.append(empty);
      return;
    }

    features.sort(sortFeatures).forEach((feature) => {
      list.append(createFeatureCard(feature));
    });
  });
}

function getVisibleFeatures(app) {
  const query = state.searchQuery.trim().toLowerCase();
  if (!query) return app.features;

  return app.features.filter((feature) => {
    return [feature.title, feature.note, feature.targetVersion, statusLabels[feature.status], priorityLabels[feature.priority]]
      .join(" ")
      .toLowerCase()
      .includes(query);
  });
}

function sortFeatures(a, b) {
  const priorityWeight = { high: 3, medium: 2, low: 1 };
  const priorityDiff = priorityWeight[b.priority] - priorityWeight[a.priority];
  if (priorityDiff !== 0) return priorityDiff;
  return b.updatedAt - a.updatedAt;
}

function createFeatureCard(feature) {
  const card = els.featureCardTemplate.content.firstElementChild.cloneNode(true);
  const titleInput = card.querySelector(".card-title-input");
  const versionInput = card.querySelector(".card-version-input");
  const prioritySelect = card.querySelector(".card-priority-select");
  const noteInput = card.querySelector(".card-note-input");
  const statusSelect = card.querySelector(".card-status-select");
  const deleteButton = card.querySelector("button");
  const updated = card.querySelector(".card-updated");

  titleInput.value = feature.title;
  versionInput.value = feature.targetVersion;
  prioritySelect.value = feature.priority;
  noteInput.value = feature.note;
  statusSelect.value = feature.status;
  updated.textContent = `수정 ${formatDate(feature.updatedAt)}`;

  titleInput.addEventListener("change", () => updateFeature(feature, { title: titleInput.value.trim() || feature.title }));
  versionInput.addEventListener("change", () => updateFeature(feature, { targetVersion: versionInput.value.trim() }));
  prioritySelect.addEventListener("change", () => updateFeature(feature, { priority: prioritySelect.value }));
  noteInput.addEventListener("change", () => updateFeature(feature, { note: noteInput.value.trim() }));
  statusSelect.addEventListener("change", () => updateFeature(feature, { status: statusSelect.value }));

  deleteButton.addEventListener("click", () => {
    const app = getCurrentApp();
    app.features = app.features.filter((item) => item.id !== feature.id);
    render();
  });

  return card;
}

function updateFeature(feature, patch) {
  Object.assign(feature, patch);
  touch(feature);
  render();
}

function formatDate(timestamp) {
  return new Intl.DateTimeFormat("ko-KR", {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(timestamp);
}

function exportState() {
  const payload = JSON.stringify(state, null, 2);
  const blob = new Blob([payload], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `build-notes-${new Date().toISOString().slice(0, 10)}.json`;
  link.click();
  URL.revokeObjectURL(url);
}

els.appForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const name = els.appName.value.trim();
  if (!name) return;

  const app = {
    id: createId("app"),
    name,
    repoUrl: "",
    features: [],
  };

  state.apps.push(app);
  state.selectedAppId = app.id;
  els.appName.value = "";
  render();
});

els.featureForm.addEventListener("submit", (event) => {
  event.preventDefault();
  const app = getCurrentApp();
  const title = els.featureTitle.value.trim();
  if (!app || !title) return;

  const now = Date.now();
  app.features.push({
    id: createId("feature"),
    title,
    status: els.featureStatus.value,
    priority: els.featurePriority.value,
    targetVersion: els.featureVersion.value.trim(),
    note: "",
    createdAt: now,
    updatedAt: now,
  });

  els.featureTitle.value = "";
  els.featureVersion.value = "";
  els.featurePriority.value = "medium";
  els.featureStatus.value = "planned";
  render();
});

els.featureSearch.addEventListener("input", () => {
  state.searchQuery = els.featureSearch.value;
  render();
});

els.saveRepo.addEventListener("click", () => {
  const app = getCurrentApp();
  if (!app) return;

  app.repoUrl = els.repoUrl.value.trim();
  els.saveRepo.textContent = "저장됨";
  window.setTimeout(() => {
    els.saveRepo.textContent = "연결";
  }, 900);
  render();
});

els.exportData.addEventListener("click", exportState);

els.importData.addEventListener("click", () => {
  els.importFile.click();
});

els.importFile.addEventListener("change", async () => {
  const file = els.importFile.files?.[0];
  if (!file) return;

  try {
    const imported = JSON.parse(await file.text());
    state = normalizeState(imported);
    render();
  } catch {
    window.alert("가져올 수 없는 JSON 파일입니다.");
  } finally {
    els.importFile.value = "";
  }
});

render();
