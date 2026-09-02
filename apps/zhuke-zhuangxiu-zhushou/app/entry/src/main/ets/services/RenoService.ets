import { HttpClient } from './HttpClient'
import { AuthService } from './AuthService'
import { RenoCatalog } from './RenoCatalog'
import { RenoLocalStore } from './RenoLocalStore'
import {
  ListPayload,
  LocalBundle,
  RenoDates,
  RenoExpense,
  RenoInspect,
  RenoMaterial,
  RenoNote,
  RenoProject,
  RenoTask,
  RenoWriteBody
} from '../models/RenoModels'

const BASE = '/biz/reno-assist'

export class RenoService {
  private static lastHydratedUser: string = ''

  static actorId(): string {
    const name = AppStorage.get<string>('currentUsername') ?? ''
    return name.length > 0 ? name : 'local'
  }

  static currentProject(): RenoProject | null {
    const id = RenoLocalStore.currentId()
    const rows = RenoLocalStore.projects()
    for (const row of rows) {
      if (row.id === id) {
        return RenoLocalStore.mapProject(row)
      }
    }
    if (rows.length > 0) {
      return RenoLocalStore.mapProject(rows[0])
    }
    return null
  }

  static async setCurrent(id: string): Promise<void> {
    await RenoLocalStore.setCurrent(id)
  }

  static async hydrateUser(): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const uid = RenoService.actorId()
    if (RenoService.lastHydratedUser === uid) {
      return
    }
    await RenoService.pullIfLoggedIn('projects')
    await RenoService.pullIfLoggedIn('tasks')
    await RenoService.pullIfLoggedIn('materials')
    await RenoService.pullIfLoggedIn('records')
    RenoService.lastHydratedUser = uid
  }

  static async projects(): Promise<RenoProject[]> {
    return RenoService.syncProjects()
  }

  static syncProjects(): RenoProject[] {
    const mapped: RenoProject[] = []
    for (const row of RenoLocalStore.projects()) {
      mapped.push(RenoLocalStore.mapProject(row))
    }
    return mapped
  }

  static async tasks(projectId: string): Promise<RenoTask[]> {
    return RenoService.syncTasks(projectId)
  }

  static syncTasks(projectId: string): RenoTask[] {
    const out: RenoTask[] = []
    for (const row of RenoLocalStore.tasks()) {
      if (projectId.length === 0 || row.projectId === projectId) {
        out.push(RenoLocalStore.mapTask(row))
      }
    }
    return out
  }

  static async materials(projectId: string): Promise<RenoMaterial[]> {
    return RenoService.syncMaterials(projectId)
  }

  static syncMaterials(projectId: string): RenoMaterial[] {
    const out: RenoMaterial[] = []
    for (const row of RenoLocalStore.materials()) {
      if (projectId.length === 0 || row.projectId === projectId) {
        out.push(RenoLocalStore.mapMaterial(row))
      }
    }
    return out
  }

  static async notes(projectId: string): Promise<RenoNote[]> {
    return RenoService.syncNotes(projectId)
  }

  static syncNotes(projectId: string): RenoNote[] {
    const out: RenoNote[] = []
    for (const row of RenoLocalStore.notes()) {
      if (projectId.length === 0 || row.projectId === projectId) {
        out.push(RenoLocalStore.mapNote(row))
      }
    }
    return out
  }

  static todayTasks(all: RenoTask[]): RenoTask[] {
    const today = RenoDates.today()
    const out: RenoTask[] = []
    for (const row of all) {
      if (row.status !== 'done' && (row.date === today || row.date.length === 0)) {
        out.push(row)
      }
    }
    return out
  }

  static pendingMaterials(all: RenoMaterial[]): RenoMaterial[] {
    const out: RenoMaterial[] = []
    for (const row of all) {
      if (row.status === 'pending') {
        out.push(row)
      }
    }
    return out
  }

  static recentNotes(all: RenoNote[], maxCount: number): RenoNote[] {
    const out: RenoNote[] = []
    for (const row of all) {
      if (out.length < maxCount) {
        out.push(row)
      }
    }
    return out
  }

  static findProject(id: string): RenoProject {
    for (const row of RenoLocalStore.projects()) {
      if (row.id === id) {
        return RenoLocalStore.mapProject(row)
      }
    }
    return new RenoProject()
  }

  static findTask(id: string): RenoTask {
    for (const row of RenoLocalStore.tasks()) {
      if (row.id === id) {
        return RenoLocalStore.mapTask(row)
      }
    }
    return new RenoTask()
  }

  static findMaterial(id: string): RenoMaterial {
    for (const row of RenoLocalStore.materials()) {
      if (row.id === id) {
        return RenoLocalStore.mapMaterial(row)
      }
    }
    return new RenoMaterial()
  }

  static findNote(id: string): RenoNote {
    for (const row of RenoLocalStore.notes()) {
      if (row.id === id) {
        return RenoLocalStore.mapNote(row)
      }
    }
    return new RenoNote()
  }

  static findInspect(id: string): RenoInspect {
    for (const row of RenoLocalStore.inspections()) {
      if (row.id === id) {
        return RenoLocalStore.mapInspect(row)
      }
    }
    return new RenoInspect()
  }

  static async saveProject(draft: RenoProject, isEdit: boolean): Promise<string> {
    const row = RenoLocalStore.mapProject(draft)
    row.title = row.title.trim()
    row.userId = RenoService.actorId()
    row.updatedAt = RenoLocalStore.nowIso()
    if (!isEdit || row.id.length === 0) {
      row.id = RenoLocalStore.newId('prj')
      row.progress = RenoService.stageBase(row.stage)
      const next = RenoLocalStore.projects().slice()
      next.unshift(row)
      await RenoService.commitProjects(next, row.id)
      await RenoService.pushCreate('projects', RenoService.projectBody(row))
      return row.id
    }
    await RenoService.commitProjects(RenoService.replaceProject(row), '')
    await RenoService.pushUpdate('projects', row.id, RenoService.projectBody(row))
    return row.id
  }

  static async removeProject(id: string): Promise<void> {
    const projects: RenoProject[] = []
    for (const row of RenoLocalStore.projects()) {
      if (row.id !== id) {
        projects.push(row)
      }
    }
    const tasks: RenoTask[] = []
    for (const row of RenoLocalStore.tasks()) {
      if (row.projectId !== id) {
        tasks.push(row)
      }
    }
    const materials: RenoMaterial[] = []
    for (const row of RenoLocalStore.materials()) {
      if (row.projectId !== id) {
        materials.push(row)
      }
    }
    const notes: RenoNote[] = []
    for (const row of RenoLocalStore.notes()) {
      if (row.projectId !== id) {
        notes.push(row)
      }
    }
    const inspections: RenoInspect[] = []
    for (const row of RenoLocalStore.inspections()) {
      if (row.projectId !== id) {
        inspections.push(row)
      }
    }
    const expenses: RenoExpense[] = []
    for (const row of RenoLocalStore.expenses()) {
      if (row.projectId !== id) {
        expenses.push(row)
      }
    }
    const bundle = new LocalBundle()
    bundle.projects = projects
    bundle.tasks = tasks
    bundle.materials = materials
    bundle.notes = notes
    bundle.inspections = inspections
    bundle.expenses = expenses
    bundle.currentId = RenoLocalStore.currentId() === id ? (projects.length > 0 ? projects[0].id : '') : RenoLocalStore.currentId()
    await RenoLocalStore.replaceAll(bundle)
    await RenoService.pushDelete('projects', id)
  }

  static async saveTask(draft: RenoTask, isEdit: boolean): Promise<void> {
    const row = RenoLocalStore.mapTask(draft)
    row.title = row.title.trim()
    row.userId = RenoService.actorId()
    row.updatedAt = RenoLocalStore.nowIso()
    if (row.date.length === 0) {
      row.date = RenoDates.today()
    }
    if (!isEdit || row.id.length === 0) {
      row.id = RenoLocalStore.newId('task')
      const next = RenoLocalStore.tasks().slice()
      next.unshift(row)
      await RenoService.commitTasks(next)
      await RenoService.pushCreate('tasks', RenoService.taskBody(row))
    } else {
      await RenoService.commitTasks(RenoService.replaceTask(row))
      await RenoService.pushUpdate('tasks', row.id, RenoService.taskBody(row))
    }
    await RenoService.recompute(row.projectId)
  }

  static async cycleTask(id: string): Promise<void> {
    const row = RenoService.findTask(id)
    if (row.id.length === 0) {
      return
    }
    if (row.status === 'todo') {
      row.status = 'doing'
    } else if (row.status === 'doing') {
      row.status = 'done'
    } else {
      row.status = 'todo'
    }
    await RenoService.saveTask(row, true)
  }

  static async removeTask(id: string): Promise<void> {
    const row = RenoService.findTask(id)
    const next: RenoTask[] = []
    for (const it of RenoLocalStore.tasks()) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await RenoService.commitTasks(next)
    await RenoService.pushDelete('tasks', id)
    await RenoService.recompute(row.projectId)
  }

  static async saveMaterial(draft: RenoMaterial, isEdit: boolean): Promise<void> {
    const row = RenoLocalStore.mapMaterial(draft)
    row.title = row.title.trim()
    row.userId = RenoService.actorId()
    row.updatedAt = RenoLocalStore.nowIso()
    if (!isEdit || row.id.length === 0) {
      row.id = RenoLocalStore.newId('mat')
      const next = RenoLocalStore.materials().slice()
      next.unshift(row)
      await RenoService.commitMaterials(next)
      await RenoService.pushCreate('materials', RenoService.materialBody(row))
      return
    }
    await RenoService.commitMaterials(RenoService.replaceMaterial(row))
    await RenoService.pushUpdate('materials', row.id, RenoService.materialBody(row))
  }

  static async removeMaterial(id: string): Promise<void> {
    const next: RenoMaterial[] = []
    for (const it of RenoLocalStore.materials()) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await RenoService.commitMaterials(next)
    await RenoService.pushDelete('materials', id)
  }

  static async saveNote(draft: RenoNote, isEdit: boolean): Promise<void> {
    const row = RenoLocalStore.mapNote(draft)
    row.title = row.title.trim()
    row.userId = RenoService.actorId()
    row.updatedAt = RenoLocalStore.nowIso()
    if (row.date.length === 0) {
      row.date = RenoDates.today()
    }
    if (!isEdit || row.id.length === 0) {
      row.id = RenoLocalStore.newId('note')
      const next = RenoLocalStore.notes().slice()
      next.unshift(row)
      await RenoService.commitNotes(next)
      await RenoService.pushCreate('records', RenoService.noteBody(row))
      return
    }
    await RenoService.commitNotes(RenoService.replaceNote(row))
    await RenoService.pushUpdate('records', row.id, RenoService.noteBody(row))
  }

  static async removeNote(id: string): Promise<void> {
    const next: RenoNote[] = []
    for (const it of RenoLocalStore.notes()) {
      if (it.id !== id) {
        next.push(it)
      }
    }
    await RenoService.commitNotes(next)
    await RenoService.pushDelete('records', id)
  }

  static async inspectForProject(projectId: string): Promise<RenoInspect[]> {
    const templates = await RenoCatalog.acceptItems('')
    const saved = RenoLocalStore.inspections()
    const out: RenoInspect[] = []
    for (const tpl of templates) {
      let found = new RenoInspect()
      for (const row of saved) {
        if (row.projectId === projectId && row.itemKey === tpl.id) {
          found = RenoLocalStore.mapInspect(row)
        }
      }
      if (found.id.length === 0) {
        found.id = `insp_${projectId}_${tpl.id}`
        found.title = tpl.title
        found.category = tpl.category
        found.body = tpl.body
        found.coverKey = tpl.coverKey
        found.itemKey = tpl.id
        found.projectId = projectId
        found.result = 'pending'
        found.userId = RenoService.actorId()
      }
      out.push(found)
    }
    return out
  }

  static inspectRate(rows: RenoInspect[]): number {
    let n = 0
    for (const row of rows) {
      if (row.result === 'pass' || row.result === 'na') {
        n += 1
      }
    }
    return n
  }

  static async setInspectResult(row: RenoInspect, result: string): Promise<void> {
    row.result = result
    row.userId = RenoService.actorId()
    row.updatedAt = RenoLocalStore.nowIso()
    let exists = false
    const replaced: RenoInspect[] = []
    for (const it of RenoLocalStore.inspections()) {
      if (it.id === row.id || (it.projectId === row.projectId && it.itemKey === row.itemKey)) {
        replaced.push(row)
        exists = true
      } else {
        replaced.push(it)
      }
    }
    if (!exists) {
      replaced.unshift(row)
    }
    const bundle = RenoLocalStore.snapshot()
    bundle.inspections = replaced
    await RenoLocalStore.replaceAll(bundle)
    if (exists) {
      await RenoService.pushUpdate('inspections', row.id, RenoService.inspectBody(row))
    } else {
      await RenoService.pushCreate('inspections', RenoService.inspectBody(row))
    }
  }

  static async clearAll(): Promise<void> {
    await RenoLocalStore.clearAll()
  }

  static exportText(): string {
    const p = RenoLocalStore.projects().length
    const t = RenoLocalStore.tasks().length
    const m = RenoLocalStore.materials().length
    const n = RenoLocalStore.notes().length
    return `筑科装修助手本地数据\n项目 ${p} · 事项 ${t} · 材料 ${m} · 记录 ${n}`
  }

  static stageBase(stage: string): number {
    const idx = RenoDates.indexOf(stage)
    return Math.min(96, idx * 16)
  }

  static taskDoneCount(rows: RenoTask[]): number {
    let n = 0
    for (const row of rows) {
      if (row.status === 'done') {
        n += 1
      }
    }
    return n
  }

  private static async recompute(projectId: string): Promise<void> {
    if (projectId.length === 0) {
      return
    }
    const project = RenoService.findProject(projectId)
    if (project.id.length === 0) {
      return
    }
    const tasks = await RenoService.tasks(projectId)
    const base = RenoService.stageBase(project.stage)
    if (tasks.length === 0) {
      project.progress = base
    } else {
      const extra = Math.round((RenoService.taskDoneCount(tasks) * 16) / tasks.length)
      project.progress = Math.min(100, base + extra)
    }
    project.status = project.progress >= 100 ? 'done' : 'active'
    project.updatedAt = RenoLocalStore.nowIso()
    await RenoService.commitProjects(RenoService.replaceProject(project), '')
  }

  private static async commitProjects(rows: RenoProject[], currentId: string): Promise<void> {
    const bundle = RenoLocalStore.snapshot()
    bundle.projects = rows
    if (currentId.length > 0) {
      bundle.currentId = currentId
    }
    await RenoLocalStore.replaceAll(bundle)
  }

  private static async commitTasks(rows: RenoTask[]): Promise<void> {
    const bundle = RenoLocalStore.snapshot()
    bundle.tasks = rows
    await RenoLocalStore.replaceAll(bundle)
  }

  private static async commitMaterials(rows: RenoMaterial[]): Promise<void> {
    const bundle = RenoLocalStore.snapshot()
    bundle.materials = rows
    await RenoLocalStore.replaceAll(bundle)
  }

  private static async commitNotes(rows: RenoNote[]): Promise<void> {
    const bundle = RenoLocalStore.snapshot()
    bundle.notes = rows
    await RenoLocalStore.replaceAll(bundle)
  }

  private static replaceProject(row: RenoProject): RenoProject[] {
    const next: RenoProject[] = []
    for (const it of RenoLocalStore.projects()) {
      next.push(it.id === row.id ? row : it)
    }
    return next
  }

  private static replaceTask(row: RenoTask): RenoTask[] {
    const next: RenoTask[] = []
    for (const it of RenoLocalStore.tasks()) {
      next.push(it.id === row.id ? row : it)
    }
    return next
  }

  private static replaceMaterial(row: RenoMaterial): RenoMaterial[] {
    const next: RenoMaterial[] = []
    for (const it of RenoLocalStore.materials()) {
      next.push(it.id === row.id ? row : it)
    }
    return next
  }

  private static replaceNote(row: RenoNote): RenoNote[] {
    const next: RenoNote[] = []
    for (const it of RenoLocalStore.notes()) {
      next.push(it.id === row.id ? row : it)
    }
    return next
  }

  private static async pullIfLoggedIn(kind: string): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const uid = encodeURIComponent(RenoService.actorId())
    const path = `${BASE}/${kind}?userId=${uid}`
    const bundle = RenoLocalStore.snapshot()
    if (kind === 'projects') {
      const res = await HttpClient.get<ListPayload<RenoProject>>(path)
      if (res.code !== 0) {
        return
      }
      const list = RenoCatalog.values(res.data)
      if (list.length === 0) {
        return
      }
      const mapped: RenoProject[] = []
      for (const row of list) {
        mapped.push(RenoLocalStore.mapProject(row))
      }
      bundle.projects = mapped
    } else if (kind === 'tasks') {
      const res = await HttpClient.get<ListPayload<RenoTask>>(path)
      if (res.code !== 0) {
        return
      }
      const list = RenoCatalog.values(res.data)
      if (list.length === 0) {
        return
      }
      const mapped: RenoTask[] = []
      for (const row of list) {
        mapped.push(RenoLocalStore.mapTask(row))
      }
      bundle.tasks = mapped
    } else if (kind === 'materials') {
      const res = await HttpClient.get<ListPayload<RenoMaterial>>(path)
      if (res.code !== 0) {
        return
      }
      const list = RenoCatalog.values(res.data)
      if (list.length === 0) {
        return
      }
      const mapped: RenoMaterial[] = []
      for (const row of list) {
        mapped.push(RenoLocalStore.mapMaterial(row))
      }
      bundle.materials = mapped
    } else if (kind === 'records') {
      const res = await HttpClient.get<ListPayload<RenoNote>>(path)
      if (res.code !== 0) {
        return
      }
      const list = RenoCatalog.values(res.data)
      if (list.length === 0) {
        return
      }
      const mapped: RenoNote[] = []
      for (const row of list) {
        mapped.push(RenoLocalStore.mapNote(row))
      }
      bundle.notes = mapped
    } else {
      return
    }
    await RenoLocalStore.replaceAll(bundle)
  }

  private static async pushCreate(kind: string, body: RenoWriteBody): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    await HttpClient.post<RenoProject>(`${BASE}/${kind}`, body)
  }

  private static async pushUpdate(kind: string, id: string, body: RenoWriteBody): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    await HttpClient.put<RenoProject>(`${BASE}/${kind}/${id}`, body)
  }

  private static async pushDelete(kind: string, id: string): Promise<void> {
    if (!AuthService.isLoggedIn()) {
      return
    }
    const uid = encodeURIComponent(RenoService.actorId())
    await HttpClient.delete<RenoProject>(`${BASE}/${kind}/${id}?userId=${uid}`)
  }

  private static projectBody(row: RenoProject): RenoWriteBody {
    const body = new RenoWriteBody()
    body.title = row.title
    body.houseType = row.houseType
    body.startDate = row.startDate
    body.stage = row.stage
    body.progress = row.progress
    body.remark = row.remark
    body.status = row.status
    body.userId = row.userId
    return body
  }

  private static taskBody(row: RenoTask): RenoWriteBody {
    const body = new RenoWriteBody()
    body.title = row.title
    body.stage = row.stage
    body.status = row.status
    body.remindAt = row.remindAt
    body.remark = row.remark
    body.date = row.date
    body.projectId = row.projectId
    body.userId = row.userId
    return body
  }

  private static materialBody(row: RenoMaterial): RenoWriteBody {
    const body = new RenoWriteBody()
    body.title = row.title
    body.brand = row.brand
    body.model = row.model
    body.spec = row.spec
    body.qty = row.qty
    body.room = row.room
    body.status = row.status
    body.remark = row.remark
    body.projectId = row.projectId
    body.userId = row.userId
    return body
  }

  private static noteBody(row: RenoNote): RenoWriteBody {
    const body = new RenoWriteBody()
    body.title = row.title
    body.body = row.body
    body.kind = row.kind
    body.date = row.date
    body.stage = row.stage
    body.photoUri = row.photoUri
    body.remark = row.remark
    body.projectId = row.projectId
    body.userId = row.userId
    return body
  }

  private static inspectBody(row: RenoInspect): RenoWriteBody {
    const body = new RenoWriteBody()
    body.title = row.title
    body.category = row.category
    body.result = row.result
    body.remark = row.remark
    body.itemKey = row.itemKey
    body.body = row.body
    body.projectId = row.projectId
    body.userId = row.userId
    body.status = row.result
    return body
  }
}
