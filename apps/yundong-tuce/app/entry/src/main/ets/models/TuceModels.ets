/** 运动图册 — 本地资料库模型（禁止匿名字面量） */

export class MoveItem {
  id: string = ''
  name: string = ''
  category: string = ''
  bodyPart: string = ''
  level: string = ''
  minutes: number = 0
  summary: string = ''
  caution: string = ''
  coverKey: string = ''
}

export class PlanItem {
  id: string = ''
  name: string = ''
  moveIds: string = ''
  reps: string = ''
  minutes: number = 20
  restSec: number = 30
  note: string = ''
  createdAt: number = 0
}

export class ProgramItem {
  id: string = ''
  name: string = ''
  days: number = 7
  planId: string = ''
  startDate: string = ''
  doneDates: string = ''
}

export class TrainLog {
  id: string = ''
  date: string = ''
  planName: string = ''
  doneText: string = ''
  feel: string = ''
  difficulty: number = 3
  fun: number = 3
  complete: number = 3
  note: string = ''
  createdAt: number = 0
}

export class ChallengeItem {
  id: string = ''
  title: string = ''
  days: number = 7
  startDate: string = ''
  doneDates: string = ''
}

export class ThemeBook {
  id: string = ''
  name: string = ''
  moveIds: string = ''
}

export class FavFolder {
  id: string = ''
  name: string = ''
  moveIds: string = ''
}

export class NoteItem {
  id: string = ''
  title: string = ''
  body: string = ''
  createdAt: number = 0
}

export class KnowledgeCard {
  id: string = ''
  moveName: string = ''
  focus: string = ''
  rhythm: string = ''
  caution: string = ''
  insight: string = ''
}

export class GoalState {
  weekly: number = 3
  monthly: number = 15
  streak: number = 7
}

export class ArchiveSnap {
  sessions: number = 0
  streak: number = 0
  plans: number = 0
  favs: number = 0
  themes: number = 0
  programsDone: number = 0
}

export class AchieveItem {
  id: string = ''
  title: string = ''
  unlocked: boolean = false
}

export class WeekDot {
  label: string = ''
  on: boolean = false
}

export class DayCell {
  key: string = ''
  day: number = 0
  count: number = 0
}

export class MixShare {
  label: string = ''
  percent: number = 0
}

export class TimelineEvent {
  date: string = ''
  title: string = ''
}

export class SuggestPack {
  title: string = ''
  reason: string = ''
  moveIds: string = ''
}

export class ChecklistItem {
  id: string = ''
  label: string = ''
  phase: string = ''
  done: boolean = false
}

export class GoalProgress {
  weeklyDone: number = 0
  weeklyTarget: number = 3
  monthlyDone: number = 0
  monthlyTarget: number = 15
  weeklyPct: number = 0
  monthlyPct: number = 0
}

export class ProgramDaySnap {
  programId: string = ''
  programName: string = ''
  planName: string = ''
  dayIndex: number = 0
  totalDays: number = 0
  todayDone: boolean = false
  moveIds: string = ''
}

export class PresetPack {
  id: string = ''
  name: string = ''
  scene: string = ''
  minutes: number = 0
  level: string = ''
  summary: string = ''
  moveIds: string = ''
  restSec: number = 30
  coverKey: string = ''
}

export class WeeklyReport {
  headline: string = ''
  weekDone: number = 0
  weekTarget: number = 3
  streak: number = 0
  topPlan: string = ''
  categoryMix: string = ''
  insight: string = ''
  nextAction: string = ''
  bodyText: string = ''
}

export class QuizResult {
  goalLabel: string = ''
  sceneLabel: string = ''
  levelLabel: string = ''
  summary: string = ''
  presetIds: string = ''
  tips: string = ''
}
