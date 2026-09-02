import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppButton } from '../design-system/AppButton'
import { PipelineSnapshot, PipelineStageItem } from '../../services/ConversionPipelineService'

class PipelineColumn {
  key: string = ''
  title: string = ''
  hint: string = ''
  items: PipelineStageItem[] = []
}

/** 转化流水线看板：四列阶段 + 就绪度入口，首屏可见差异化 */
@Component
export struct ConversionPipelineBoard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop snap: PipelineSnapshot = PipelineSnapshot.empty()
  @Prop loggedIn: boolean = false
  onOpenItem: (id: string) => void = () => {}
  onOpenCapture: () => void = () => {}
  onOpenReadiness: () => void = () => {}

  private columns(): PipelineColumn[] {
    const list: PipelineColumn[] = []
    const c0 = new PipelineColumn()
    c0.key = 'capture'
    c0.title = '待钉板'
    c0.hint = '捕捉后先对照'
    c0.items = this.snap.capture
    list.push(c0)
    const c1 = new PipelineColumn()
    c1.key = 'board'
    c1.title = '待拆计划'
    c1.hint = '已钉板待拆解'
    c1.items = this.snap.board
    list.push(c1)
    const c2 = new PipelineColumn()
    c2.key = 'plan'
    c2.title = '推进中'
    c2.hint = '步骤勾选中'
    c2.items = this.snap.plan
    list.push(c2)
    const c3 = new PipelineColumn()
    c3.key = 'done'
    c3.title = '已完成'
    c3.hint = '三步走完'
    c3.items = this.snap.done
    list.push(c3)
    return list
  }

  @Builder
  MiniRow(row: PipelineStageItem) {
    Column({ space: 2 }) {
      Text(row.inspiration.title)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      if (row.stepText.length > 0) {
        Text(row.stepText)
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      }
    }
    .width('100%')
    .padding({ top: 6, bottom: 6 })
    .onClick((): void => { this.onOpenItem(row.inspiration.id) })
  }

  @Builder
  ColumnCard(col: PipelineColumn) {
    Column({ space: Theme.space.s2 }) {
      Row() {
        Text(col.title)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        Text(`${col.items.length}`)
          .fontSize(Theme.type.caption)
          .fontWeight(FontWeight.Bold)
          .fontColor(Theme.colors().brandPrimary)
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor(Theme.colors().brandPrimaryContainer)
          .borderRadius(Theme.radius.pill)
      }
      .width('100%')
      Text(col.hint)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      if (col.items.length === 0) {
        Text('—')
          .fontSize(Theme.type.footnote)
          .fontColor(Theme.colors().textTertiary)
          .width('100%')
      } else {
        this.MiniRow(col.items[0])
        if (col.items.length > 1) {
          this.MiniRow(col.items[1])
        }
      }
    }
    .width(148)
    .padding(Theme.space.s3)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.lg)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Row() {
        Column({ space: 4 }) {
          Text('转化流水线')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Text('捕捉 → 钉板对照 → 拆计划 → 勾选推进 — 非记完即走的备忘录')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        AppIcon({ name: 'chart', iconSize: Theme.icon.md, color: Theme.colors().brandPrimary })
      }
      .width('100%')

      if (!this.loggedIn) {
        Text('登录后可见你的灵感在各转化阶段的分布')
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .width('100%')
      } else if (this.snap.totalCount() === 0) {
        Column({ space: Theme.space.s2 }) {
          Text('队列还是空的，先捕捉 1 条灵感开始转化')
            .fontSize(Theme.type.footnote)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          AppButton({ label: '开始捕捉', variant: 'primary', onTap: (): void => { this.onOpenCapture() } })
        }
        .width('100%')
      } else {
        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(this.columns(), (col: PipelineColumn) => {
              this.ColumnCard(col)
            }, (col: PipelineColumn) => col.key)
          }
          .padding({ right: Theme.space.s2 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }

      Row({ space: Theme.space.s2 }) {
        AppButton({
          label: '转化就绪度评估',
          variant: 'secondary',
          onTap: (): void => { this.onOpenReadiness() }
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
