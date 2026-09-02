/** 一键生活场景：同时生成清单 + 计划 + 备忘，覆盖多模块协同。 */
export class LifeSceneDef {
  code: string = ''
  title: string = ''
  subtitle: string = ''
  checklistKind: string = ''
  checklistTitle: string = ''
  memoTitle: string = ''
  memoBody: string = ''
  memoTag: string = ''
  taskTitles: string[] = []
}

export class SceneApplyResult {
  checklistId: string = ''
  memoId: string = ''
  taskCount: number = 0
  message: string = ''
}
