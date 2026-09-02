import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ObserveImage } from './ObserveImage'
import { ObserveSubject, CategoryOption } from '../../models/ObserveCatalog'
import { ObserveRecord } from '../../models/ObserveModels'
import { ObserveAtlasStore } from '../../services/ObserveAtlasStore'
import { ObserveStore } from '../../services/ObserveStore'
import { DateHelper } from '../../services/DateHelper'
import { ObserveMedia } from '../../services/ObserveMedia'

@Component
export struct SubjectDetailOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop subjectId: string = ''
  @Prop @Watch('onTick') refreshToken: number = 0
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onAddRecord: () => void = () => {}
  onOpenRecord: (id: string) => void = () => {}
  onDeleted: () => void = () => {}
  @State subject: ObserveSubject = new ObserveSubject()
  @State timeline: ObserveRecord[] = []
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await ObserveAtlasStore.findById(this.subjectId)
    if (found !== undefined) {
      this.subject = found
    }
    this.timeline = await ObserveStore.notesForSubject(this.subjectId)
  }

  private async handleDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await ObserveAtlasStore.deleteById(this.subjectId)
    this.onDeleted()
  }

  build() {
    Column() {
      Row() {
        Text('图鉴详情')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(Theme.colors().textPrimary)
        Blank()
        Text('关闭')
          .fontColor(Theme.colors().brandPrimary)
          .onClick((): void => this.onClose())
      }
      .width('100%')
      .padding(Theme.space.s4)

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            if (this.subject.coverPath.length > 0) {
              ObserveImage({ path: this.subject.coverPath, imgWidth: 360, imgHeight: 180, radius: 0 })
            } else {
              Image(ObserveMedia.banner())
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
            }
            Column()
              .width('100%')
              .height(80)
              .linearGradient({
                angle: 180,
                colors: [['rgba(26,26,46,0)', 0], ['rgba(26,26,46,0.88)', 1]]
              })
            Text(this.subject.name)
              .fontSize(Theme.type.title2)
              .fontColor('#FFFFFF')
              .padding({ left: Theme.space.s4, bottom: Theme.space.s4 })
          }
          .width('100%')
          .borderRadius(Theme.radius.md)
          .clip(true)

          Text(`${CategoryOption.labelOf(this.subject.categoryKey)} · 发现于 ${DateHelper.displayDate(DateHelper.keyFromDate(new Date(this.subject.createdAt)))}`)
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')

          if (this.subject.traits.length > 0) {
            Column({ space: 6 }) {
              Text('特点').fontSize(Theme.type.subhead).fontColor(Theme.colors().textSecondary)
              Text(this.subject.traits).fontSize(Theme.type.body).fontColor(Theme.colors().textPrimary)
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
          }

          Column({ space: 6 }) {
            Text('知识补充').fontSize(Theme.type.subhead).fontColor(Theme.colors().textSecondary)
            Text(this.subject.knowledge.length > 0 ? this.subject.knowledge : CategoryOption.knowledgeOf(this.subject.categoryKey))
              .fontSize(Theme.type.body)
              .fontColor(Theme.colors().textPrimary)
              .lineHeight(22)
          }
          .width('100%')
          .padding(Theme.space.s4)
          .backgroundColor(Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)

          Text(`成长时间轴 · ${this.timeline.length} 次记录`)
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
            .width('100%')

          if (this.timeline.length === 0) {
            Text('还没有针对它的观察。点下方按钮补第一条，之后可对比前后变化。')
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().textSecondary)
              .width('100%')
          } else {
            ForEach(this.timeline, (n: ObserveRecord) => {
              Row({ space: Theme.space.s3 }) {
                if (n.hasImage()) {
                  ObserveImage({ path: n.imagePaths[0], imgWidth: 56, imgHeight: 56, radius: Theme.radius.sm })
                }
                Column({ space: 4 }) {
                  Text(`${DateHelper.displayDate(n.dateKey)} · ${DateHelper.timeLabel(n.createdAt)}`)
                    .fontSize(Theme.type.caption)
                    .fontColor(Theme.colors().brandPrimary)
                  Text(n.preview())
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textPrimary)
                    .maxLines(2)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(Theme.space.s3)
              .backgroundColor(Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onClick((): void => this.onOpenRecord(n.id))
            }, (n: ObserveRecord) => n.id)
          }

          AppButton({ label: '为它补一条观察', variant: 'primary', onTap: (): void => this.onAddRecord() })
          AppButton({ label: '编辑图鉴资料', variant: 'secondary', onTap: (): void => this.onEdit() })
          AppButton({
            label: this.confirmDelete ? '再次点击确认删除图鉴' : '删除图鉴条目',
            variant: 'danger',
            onTap: (): void => { void this.handleDelete() }
          })
        }
        .padding({ left: Theme.space.s4, right: Theme.space.s4, bottom: Theme.space.s8 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
