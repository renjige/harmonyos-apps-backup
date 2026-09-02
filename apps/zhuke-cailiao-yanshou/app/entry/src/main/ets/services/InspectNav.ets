import { InspectLocalStore } from './InspectLocalStore'

export class InspectNav {
  static openCreate(): void {
    AppStorage.setOrCreate('inspectNavMode', 'create')
    AppStorage.setOrCreate('inspectNavId', '')
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openEdit(id: string): void {
    AppStorage.setOrCreate('inspectNavMode', 'edit')
    AppStorage.setOrCreate('inspectNavId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openDetail(id: string): void {
    AppStorage.setOrCreate('inspectNavMode', 'detail')
    AppStorage.setOrCreate('inspectNavId', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('inspectNavMode', '')
    AppStorage.setOrCreate('inspectNavId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    InspectLocalStore.bumpTick()
  }

  static closeToList(): void {
    AppStorage.setOrCreate('inspectNavMode', '')
    AppStorage.setOrCreate('inspectNavId', '')
    AppStorage.setOrCreate('tabBarHidden', false)
    InspectLocalStore.bumpTick()
  }

  static openGuide(category: string): void {
    AppStorage.setOrCreate('inspectExtraMode', 'guide')
    AppStorage.setOrCreate('inspectExtraKey', category)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openFollow(id: string): void {
    AppStorage.setOrCreate('inspectExtraMode', 'follow')
    AppStorage.setOrCreate('inspectExtraKey', id)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openFollowList(): void {
    AppStorage.setOrCreate('inspectExtraMode', 'followList')
    AppStorage.setOrCreate('inspectExtraKey', '')
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openBoard(mode: string, key: string = ''): void {
    AppStorage.setOrCreate('inspectExtraMode', 'board')
    AppStorage.setOrCreate('inspectExtraKey', mode)
    AppStorage.setOrCreate('inspectBoardFilter', key)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openProjectBoard(projectName: string): void {
    InspectNav.openBoard('project', projectName)
  }

  static openSupplierBoard(supplier: string): void {
    InspectNav.openBoard('supplier', supplier)
  }

  static closeExtra(): void {
    AppStorage.setOrCreate('inspectExtraMode', '')
    AppStorage.setOrCreate('inspectExtraKey', '')
    AppStorage.setOrCreate('inspectBoardFilter', '')
    const mode = AppStorage.get<string>('inspectNavMode')
    if (mode === undefined || mode.length === 0) {
      AppStorage.setOrCreate('tabBarHidden', false)
    }
    InspectLocalStore.bumpTick()
  }
}
