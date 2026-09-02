import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppIcon } from '../design-system/AppIcon'
import { FieldRecord } from '../../models/FieldModels'
import { GewuDetailNav } from '../../services/GewuDetailNav'
import { GewuMedia } from '../../services/GewuMedia'
import { DateHelper } from '../../services/DateHelper'

@Component
export struct ObservationArchiveSection {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop records: FieldRecord[] = []
  @StorageLink('recordDateFilter') @Watch('onDateFilter') recordDateFilter: string = ''

  private goPickFromAtlas(): void {
    AppStorage.setOrCreate('folioListMode', 'all')
    AppStorage.setOrCreate('folioAtlasFilter', 'all')
    AppStorage.setOrCreate('switchTabIndex', 1)
  }

  onDateFilter(): void {
    // 触发父页 reload 由 refreshToken 负责
  }

  private visible(): FieldRecord[] {
    const out: FieldRecord[] = []
    for (const r of this.records) {
      if (this.recordDateFilter.length > 0 && r.dateKey !== this.recordDateFilter) {
        continue
      }
      out.push(r)
    }
    return out
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column({ space: 4 }) {
          Text('图鉴观察札')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('从图鉴选物写入，含模板与对照（非独立记事本）')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      if (this.recordDateFilter.length > 0) {
        Text(`筛选 ${this.recordDateFilter} · 点此清除`)
          .fontSize(Theme.type.caption)
          .fontColor(Theme.colors().brandPrimary)
          .width('100%')
          .onClick((): void => { AppStorage.setOrCreate('recordDateFilter', '') })
      }

      if (this.visible().length === 0) {
        AppEmpty({
          title: this.records.length === 0 ? '还没有观察札' : '该日暂无观察札',
          description: '请从图鉴选一物，在详情页用观察模板写下发现',
          actionLabel: '去图鉴选物',
          onAction: (): void => { this.goPickFromAtlas() }
        })
      } else {
        Column({ space: Theme.space.s2 }) {
          ForEach(this.visible(), (r: FieldRecord) => {
            Row({ space: Theme.space.s3 }) {
              Image(GewuMedia.coverResource(r.coverKey))
                .width(56)
                .height(56)
                .objectFit(ImageFit.Cover)
                .borderRadius(12)
              Column({ space: 4 }) {
                Text(r.title)
                  .fontSize(Theme.type.bodyS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .maxLines(1)
                Text(`${r.atlasKind} · ${DateHelper.displayShort(r.dateKey)}`)
                  .fontSize(Theme.type.caption)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().textTertiary })
            }
            .width('100%')
            .padding(12)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { GewuDetailNav.openRecord(r.id) })
          }, (r: FieldRecord) => r.id)
        }
        .width('100%')
      }

      AppButton({
        label: '去图鉴选物写札',
        variant: 'secondary',
        onTap: (): void => { this.goPickFromAtlas() }
      })
    }
    .width('100%')
  }
}
