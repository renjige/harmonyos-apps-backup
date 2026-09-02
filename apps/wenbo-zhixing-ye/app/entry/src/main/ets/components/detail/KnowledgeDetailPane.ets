import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppCard } from '../design-system/AppCard'
import { KnowledgeItem, PlanTask, StudyPlan } from '../../models/ZhixingModels'
import { ZhixingMedia } from '../../services/ZhixingMedia'
import { ZhixingStore } from '../../services/ZhixingStore'
import { RecommendService } from '../../services/RecommendService'
import { CategoryEmojiUtil } from '../../utils/CategoryEmojiUtil'
import { DetailShell } from '../detail/DetailShell'

@Component
export struct KnowledgeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @State item: KnowledgeItem = new KnowledgeItem()
  @State related: KnowledgeItem[] = []
  @State confirmDelete: boolean = false
  @State toastText: string = ''
  onClose: () => void = () => {}
  onEdit: (id: string, kind: string) => void = (_id: string, _k: string) => {}
  onOpenRelated: (id: string) => void = (_id: string) => {}
  onStartFocus: (id: string, title: string) => void = (_id: string, _t: string) => {}
  onDeleted: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const found = await ZhixingStore.findItem(this.itemId)
    if (found !== undefined) {
      this.item = found
      const pool = await ZhixingStore.loadItems()
      this.related = RecommendService.related(found, pool)
    }
  }

  private async toggleFav(): Promise<void> {
    this.item.favorite = !this.item.favorite
    await ZhixingStore.saveItem(this.item)
    this.toastText = this.item.favorite ? '已收藏' : '已取消收藏'
    setTimeout((): void => { this.toastText = '' }, 1800)
  }

  private async convertToPlan(): Promise<void> {
    const p = StudyPlan.createNew()
    p.title = this.item.title.length > 0 ? this.item.title : '未命名计划'
    const goal = this.item.summary.length > 0 ? this.item.summary : this.item.body
    p.goal = goal.length > 0 ? goal : '把这张知识卡片拆成可跟踪的行动'
    p.knowledgeId = this.item.id
    p.progress = 0
    p.tasks.push(PlanTask.create('梳理要点'))
    p.tasks.push(PlanTask.create('制定第一步行动'))
    p.tasks.push(PlanTask.create('复盘并写日志'))
    p.syncProgressFromTasks()
    await ZhixingStore.savePlan(p)
    this.toastText = '已转入行录学习计划，含 3 个子任务'
    setTimeout((): void => { this.toastText = '' }, 2200)
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      this.toastText = '再点一次确认删除'
      setTimeout((): void => { this.toastText = '' }, 2200)
      return
    }
    await ZhixingStore.deleteItem(this.item.id)
    this.onDeleted()
  }

  build() {
    Stack() {
      DetailShell({
        title: this.item.kindLabel(),
        onClose: (): void => { this.onClose() }
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(ZhixingMedia.image(this.item.coverKey))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(90)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(26,42,108,0)', 0], ['rgba(26,42,108,0.82)', 1]]
                })
              Text(this.item.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .padding({ left: 16, right: 16, bottom: 14 })
                .maxLines(2)
            }
            .width('100%')
            .height(200)
            .borderRadius(Theme.radius.md)
            .clip(true)

            Text(this.item.kindLabel() + (this.item.source.length > 0 ? ` · ${this.item.source}` : ''))
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
              .width('100%')

            AppCard({ title: '摘要' }) {
              Text(this.item.summary.length > 0 ? this.item.summary : '尚未填写摘要')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }

            Column({ space: 8 }) {
              Text('正文')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              Text(this.item.body.length > 0 ? this.item.body : '尚未填写正文')
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            .width('100%')
            .padding(Theme.space.s4)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)

            if (this.item.tagList().length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.item.tagList(), (t: string) => {
                  Text(CategoryEmojiUtil.chipLabel(t))
                    .fontSize(Theme.type.caption)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                    .margin({ right: 8, bottom: 8 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                }, (t: string) => t)
              }
              .width('100%')
            }

            if (this.related.length > 0) {
              Text('图谱关联')
                .fontSize(Theme.type.subhead)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.related, (r: KnowledgeItem) => {
                Text(r.title)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                  .padding({ top: 8, bottom: 8 })
                  .onClick((): void => { this.onOpenRelated(r.id) })
              }, (r: KnowledgeItem) => r.id)
            }

            AppButton({
              label: '开始专注 25 分钟',
              onTap: (): void => { this.onStartFocus(this.item.id, this.item.title) }
            })
            AppButton({
              label: this.item.favorite ? '取消收藏' : '收藏',
              variant: 'secondary',
              onTap: (): void => { void this.toggleFav() }
            })
            AppButton({
              label: '转入学习计划',
              variant: 'secondary',
              onTap: (): void => { void this.convertToPlan() }
            })
            AppButton({
              label: '编辑',
              onTap: (): void => { this.onEdit(this.item.id, this.item.kind) }
            })
            AppButton({
              label: this.confirmDelete ? '再点一次确认删除' : '删除',
              variant: 'danger',
              onTap: (): void => { void this.remove() }
            })
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
          .width('100%')
        }
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.footnote)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandDeep)
          .borderRadius(Theme.radius.pill)
          .margin({ top: 12 })
      }
    }
    .width('100%')
    .height('100%')
  }
}
