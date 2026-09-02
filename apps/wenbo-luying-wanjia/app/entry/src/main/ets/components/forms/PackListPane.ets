import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { CampBizService } from '../../services/CampBizService'
import { CampDetailNav } from '../../services/CampDetailNav'
import { CampWriteRequest, CatalogItem } from '../../models/CampModels'
import { DetailShell } from '../detail/DetailShell'

class PackRow {
  name: string = ''
  weightG: number = 0
  checked: boolean = false
  id: string = ''
}

@Component
export struct PackListPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State rows: PackRow[] = []
  @State totalG: number = 0
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const gear = await CampBizService.loadMine('gear')
    const next: PackRow[] = []
    let sum = 0
    for (const g of gear) {
      const r = new PackRow()
      r.id = g.id
      r.name = g.title
      r.weightG = g.weightG
      r.checked = true
      sum += g.weightG
      next.push(r)
    }
    this.rows = next
    this.totalG = sum
  }

  private toggle(id: string): void {
    const next: PackRow[] = []
    let sum = 0
    for (const r of this.rows) {
      const n = new PackRow()
      n.id = r.id
      n.name = r.name
      n.weightG = r.weightG
      n.checked = r.id === id ? !r.checked : r.checked
      if (n.checked) {
        sum += n.weightG
      }
      next.push(n)
    }
    this.rows = next
    this.totalG = sum
  }

  private async save(): Promise<void> {
    const tripId = AppStorage.get<string>('packDraftTrip') ?? ''
    let items = ''
    for (const r of this.rows) {
      if (r.checked) {
        if (items.length > 0) {
          items += '|'
        }
        items += `${r.name} ${r.weightG}`
      }
    }
    const req = new CampWriteRequest()
    req.title = '行程打包清单'
    req.tripId = tripId
    req.itemsJson = items
    req.totalWeightG = this.totalG
    const ok = await CampBizService.create('packlists', req)
    this.toastText = ok ? `已保存 · ${(this.totalG / 1000).toFixed(1)} kg` : '保存失败'
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({ title: '打包清单', onClose: () => CampDetailNav.close() }) {
        Column({ space: 12 }) {
          Text(`已勾选 ${(this.totalG / 1000).toFixed(1)} kg`)
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .width('100%')
          if (this.rows.length === 0) {
            AppEmpty({
              title: '装备库还是空的',
              description: '先在「装备」添加或套用模板',
              actionLabel: '去装备库',
              onAction: () => CampDetailNav.close()
            })
          } else {
            ForEach(this.rows, (r: PackRow) => {
              Row() {
                Text(r.checked ? '已装' : '未装')
                  .fontSize(Theme.type.caption)
                  .fontColor(r.checked ? Theme.colors().brandPrimary : Theme.colors().textTertiary)
                  .width(48)
                Text(r.name)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .layoutWeight(1)
                Text(`${r.weightG} g`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .width('100%')
              .height(48)
              .onClick(() => this.toggle(r.id))
            }, (r: PackRow) => r.id)
            AppButton({ label: '保存这份清单', onTap: () => { void this.save() } })
          }
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        .width('100%')
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding(12)
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
