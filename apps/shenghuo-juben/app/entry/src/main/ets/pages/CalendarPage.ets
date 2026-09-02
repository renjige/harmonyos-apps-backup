import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { ScriptDetailPane } from '../components/script/ScriptDetailPane'
import { DayScriptPicker } from '../components/script/DayScriptPicker'
import { CreateScriptPage } from './CreateScriptPage'
import { LifeScript, DateCountMap } from '../models/ScriptModels'
import { DateHelper } from '../services/DateHelper'
import { ScriptStore } from '../services/ScriptStore'

@Component
export struct CalendarPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State year: number = new Date().getFullYear()
  @State month: number = new Date().getMonth() + 1
  @State markedKeys: string[] = []
  @State dateCounts: DateCountMap = new DateCountMap()
  @State gridDays: number[] = []
  @State detailScript: LifeScript | undefined = undefined
  @State dayPickerScripts: LifeScript[] = []
  @State dayPickerKey: string = ''
  @State showDayPicker: boolean = false
  @State showEditor: boolean = false
  @State editTarget: LifeScript | undefined = undefined
  @Prop reloadToken: number = 0
  @State lastToken: number = -1
  private weekdayNames: string[] = ['日', '一', '二', '三', '四', '五', '六']

  aboutToAppear(): void {
    this.rebuildGrid()
    void this.reloadMarks()
  }

  private rebuildGrid(): void {
    this.gridDays = DateHelper.buildMonthGrid(this.year, this.month)
  }

  private async reloadMarks(): Promise<void> {
    this.markedKeys = await ScriptStore.dateKeysWithScripts()
    const all = await ScriptStore.loadAll()
    this.dateCounts = DateCountMap.build(all)
  }

  private prevMonth(): void {
    if (this.month === 1) {
      this.year--
      this.month = 12
    } else {
      this.month--
    }
    this.rebuildGrid()
  }

  private nextMonth(): void {
    if (this.month === 12) {
      this.year++
      this.month = 1
    } else {
      this.month++
    }
    this.rebuildGrid()
  }

  private dayCount(day: number): number {
    if (day <= 0) {
      return 0
    }
    const key = DateHelper.keyFromParts(this.year, this.month, day)
    return this.dateCounts.countFor(key)
  }

  private isMarked(day: number): boolean {
    return this.dayCount(day) > 0
  }

  private currentMonthHasScript(): boolean {
    const m = this.month < 10 ? `0${this.month}` : `${this.month}`
    const prefix = `${this.year}-${m}`
    for (const k of this.markedKeys) {
      if (k.indexOf(prefix) === 0) {
        return true
      }
    }
    return false
  }

  private async openDay(day: number): Promise<void> {
    if (day <= 0) {
      return
    }
    const key = DateHelper.keyFromParts(this.year, this.month, day)
    const list = await ScriptStore.findByDateKey(key)
    if (list.length === 0) {
      return
    }
    AppStorage.setOrCreate('tabBarHidden', true)
    if (list.length === 1) {
      this.detailScript = list[0]
      return
    }
    this.dayPickerKey = key
    this.dayPickerScripts = list
    this.showDayPicker = true
  }

  private openEdit(script: LifeScript): void {
    this.detailScript = undefined
    this.showDayPicker = false
    this.editTarget = script
    this.showEditor = true
  }

  private closeEditor(): void {
    this.showEditor = false
    this.editTarget = undefined
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .rotate({ angle: 180 })
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.prevMonth() })
          Blank()
          Text(DateHelper.monthLabel(this.year, this.month))
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Row() {
            AppIcon({ name: 'chevron', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.nextMonth() })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s2
        })

        Row() {
          ForEach(this.weekdayNames, (name: string) => {
            Text(name)
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().textTertiary)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
          }, (name: string) => name)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

        Grid() {
          ForEach(this.gridDays, (day: number, idx: number) => {
            GridItem() {
              Column({ space: 2 }) {
                Text(day > 0 ? `${day}` : '')
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                if (this.isMarked(day)) {
                  Text(this.dayCount(day) > 1 ? `${this.dayCount(day)}` : '·')
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .fontWeight(FontWeight.Medium)
                }
              }
              .width('100%')
              .height(52)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(day > 0 ? Theme.colors().surfaceCard : 'transparent')
              .borderRadius(Theme.radius.sm)
              .onClick((): void => { void this.openDay(day) })
            }
          }, (day: number, idx: number) => `${this.year}_${this.month}_${idx}_${day}`)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
        .rowsGap(8)
        .columnsGap(8)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .layoutWeight(1)

        if (!this.currentMonthHasScript()) {
          Text('本月还没有剧本，有记录的日期会出现圆点或数字')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s3 })
        }

        Image($r('app.media.banner_script_02'))
          .width('92%')
          .height(100)
          .objectFit(ImageFit.Cover)
          .borderRadius(Theme.radius.md)
          .margin({ bottom: Theme.space.s6 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.showDayPicker) {
        DayScriptPicker({
          dateKey: this.dayPickerKey,
          scripts: this.dayPickerScripts,
          onClose: (): void => {
            this.showDayPicker = false
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onPick: (script: LifeScript): void => {
            this.showDayPicker = false
            this.detailScript = script
          }
        })
      }

      if (this.detailScript !== undefined) {
        ScriptDetailPane({
          script: this.detailScript,
          onClose: (): void => {
            this.detailScript = undefined
            AppStorage.setOrCreate('tabBarHidden', false)
          },
          onEdit: (script: LifeScript): void => { this.openEdit(script) },
          onDeleted: (): void => {
            this.detailScript = undefined
            AppStorage.setOrCreate('tabBarHidden', false)
            void this.reloadMarks()
          }
        })
      }

      if (this.showEditor) {
        CreateScriptPage({
          editingId: this.editTarget !== undefined ? this.editTarget.id : '',
          onClose: (): void => { this.closeEditor() },
          onSaved: (): void => {
            this.closeEditor()
            void this.reloadMarks()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .onAppear((): void => {
      if (this.reloadToken !== this.lastToken) {
        this.lastToken = this.reloadToken
        void this.reloadMarks()
      }
    })
  }
}
