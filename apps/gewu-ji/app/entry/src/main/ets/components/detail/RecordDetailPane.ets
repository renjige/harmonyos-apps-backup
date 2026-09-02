import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { DetailShell } from './DetailShell'
import { FieldRecord } from '../../models/FieldModels'
import { KnowledgeObject } from '../../models/KnowledgeModels'
import { DateHelper } from '../../services/DateHelper'
import { FieldStore } from '../../services/FieldStore'
import { GewuDetailNav } from '../../services/GewuDetailNav'
import { GewuMedia } from '../../services/GewuMedia'
import { KnowledgeCatalog } from '../../services/KnowledgeCatalog'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct RecordDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRecordChange') recordId: string = ''
  onChanged: () => void = () => {}
  @StorageLink('detailRefreshToken') @Watch('onRecordChange') detailTick: number = 0
  @State rec: FieldRecord = new FieldRecord()
  @State timeline: FieldRecord[] = []
  @State related: KnowledgeObject[] = []
  @State confirmDelete: boolean = false
  @State toast: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRecordChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    const found = await FieldStore.findRecord(this.recordId)
    if (found === undefined) {
      return
    }
    this.rec = found
    this.timeline = await FieldStore.recordsOfSubject(found.subjectId)
    this.related = KnowledgeCatalog.relatedKnowledge(found.atlasKind, '')
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout((): void => { this.toast = '' }, 2400)
  }

  private appendFollowUp(): void {
    AppStorage.setOrCreate('recordSubjectId', this.rec.subjectId)
    AppStorage.setOrCreate('recordSeedTitle', this.rec.title)
    AppStorage.setOrCreate('recordSeedAtlas', this.rec.atlasKind)
    AppStorage.setOrCreate('recordSeedCover', this.rec.coverKey)
    GewuDetailNav.openEditor('new')
  }

  private async shareCard(): Promise<void> {
    const lines: string[] = []
    lines.push(`格物记录 · ${this.rec.title}`)
    lines.push(`${DateHelper.displayDate(this.rec.dateKey)} · ${this.rec.atlasKind}`)
    if (this.rec.place.length > 0) {
      lines.push(`地点：${this.rec.place}`)
    }
    lines.push(this.rec.body)
    lines.push('—— 来自格物集')
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, lines.join('\n'))
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('图文卡片已复制，可粘贴到备忘录或社交软件')
    } catch {
      this.showToast('复制失败')
    }
  }

  private async doDelete(): Promise<void> {
    await FieldStore.deleteRecord(this.rec.id)
    this.onChanged()
    GewuDetailNav.close()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({ title: '观察详情', onClose: (): void => GewuDetailNav.close() }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(GewuMedia.coverResource(this.rec.coverKey))
                .width('100%')
                .height(180)
                .objectFit(ImageFit.Cover)
                .borderRadius(16)
              Column()
                .width('100%')
                .height(80)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(26,58,92,0.72)', 1]]
                })
                .borderRadius({ bottomLeft: 16, bottomRight: 16 })
              Text(this.rec.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .padding({ left: 16, bottom: 12 })
            }
            .clip(true)
            .borderRadius(16)

            Text(`${this.rec.atlasKind} · ${DateHelper.displayDate(this.rec.dateKey)}`)
              .fontSize(Theme.type.bodyS)
              .fontColor(Theme.colors().brandPrimary)
              .width('100%')
            if (this.rec.place.length > 0) {
              Text(`地点 ${this.rec.place}`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textSecondary)
                .width('100%')
            }
            AppCard({ title: '观察正文' }) {
              Text(this.rec.body)
                .fontSize(Theme.type.body)
                .fontColor(Theme.colors().textPrimary)
                .lineHeight(24)
                .width('100%')
            }

            if (this.timeline.length > 0) {
              Column({ space: Theme.space.s2 }) {
                Text('成长观察档案')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                ForEach(this.timeline, (t: FieldRecord) => {
                  Row() {
                    Text(DateHelper.displayShort(t.dateKey))
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandPrimary)
                      .width(48)
                    Text(t.preview())
                      .fontSize(Theme.type.bodyS)
                      .fontColor(Theme.colors().textSecondary)
                      .layoutWeight(1)
                      .maxLines(2)
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().surfaceSubtle)
                  .borderRadius(12)
                  .onClick((): void => { GewuDetailNav.openRecord(t.id) })
                }, (t: FieldRecord) => t.id)
              }
              .width('100%')
            }

            if (this.related.length > 0) {
              Column({ space: Theme.space.s2 }) {
                Text('相关知识补充')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                ForEach(this.related, (k: KnowledgeObject) => {
                  Text(`${k.title} · ${k.summary}`)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(Theme.colors().textSecondary)
                    .maxLines(2)
                    .width('100%')
                    .padding(Theme.space.s3)
                    .backgroundColor(Theme.colors().surfaceSubtle)
                    .borderRadius(12)
                    .onClick((): void => { GewuDetailNav.open(k.id) })
                }, (k: KnowledgeObject) => k.id)
              }
              .width('100%')
            }

            AppButton({ label: '追加一次观察（成长时间轴）', variant: 'secondary',
              onTap: (): void => this.appendFollowUp() })
            AppButton({ label: '生成图文卡片并复制', variant: 'secondary',
              onTap: (): void => { void this.shareCard() } })
            AppButton({ label: '编辑', variant: 'ghost',
              onTap: (): void => { GewuDetailNav.openEditor(this.rec.id) } })
            if (!this.confirmDelete) {
              AppButton({ label: '删除', variant: 'ghost',
                onTap: (): void => { this.confirmDelete = true } })
            } else {
              Column({ space: Theme.space.s2 }) {
                Text('确定删除这条观察？不可恢复')
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().danger)
                Row({ space: Theme.space.s2 }) {
                  Column() {
                    AppButton({ label: '取消', variant: 'secondary',
                      onTap: (): void => { this.confirmDelete = false } })
                  }.layoutWeight(1)
                  Column() {
                    AppButton({ label: '确认删除', variant: 'danger',
                      onTap: (): void => { void this.doDelete() } })
                  }.layoutWeight(1)
                }
                .width('100%')
              }
            }
            Row().height(Theme.space.s10)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s2 })
        }
        .width('100%')
        .layoutWeight(1)
      }

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(Theme.type.bodyS)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 48 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
