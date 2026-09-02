import { Theme } from '../components/design-system/Theme'
import { FamilyCategory, FamilyRhythm, FamilyTaskItem, TaskDates } from '../models/FamilyTaskModels'
import { CategorySuggest } from '../services/CategorySuggest'
import { TaskMedia } from '../services/TaskMedia'
import { TaskService } from '../services/TaskService'

@Component
export struct StatsPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State weekTotal: number = 0
  @State weekDone: number = 0
  @State weekRate: number = 0
  @State review: string = ''
  @State cats: FamilyCategory[] = []
  @State week: FamilyTaskItem[] = []
  @Prop @Watch('onTick') refreshToken: number = 0
  onOpenCategory: (item: FamilyCategory) => void = (_i: FamilyCategory) => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onTick(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const all = await TaskService.all()
    const today = TaskDates.today()
    this.week = TaskService.weekRows(all, today)
    this.weekTotal = this.week.length
    this.weekDone = TaskService.doneCount(this.week)
    this.weekRate = TaskService.progress(this.week)
    const rhythm = await TaskService.rhythm()
    this.review = TaskService.reviewLine(this.week, rhythm)
    this.cats = await TaskService.categories()
  }

  private share(title: string): number {
    return TaskService.categoryShare(this.week, title)
  }

  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('本周家庭节奏')
          .fontSize(Theme.type.titleM)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        Image($r('app.media.home_hero'))
          .width('100%')
          .height(120)
          .borderRadius(Theme.radius.xl)
          .objectFit(ImageFit.Cover)

        Row() {
          Column() {
            Text(`${this.weekTotal}`)
              .fontSize(Theme.type.displayS)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('本周事项')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          Column() {
            Text(`${this.weekDone}`)
              .fontSize(Theme.type.titleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            Text('已完成')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
          Column() {
            Text(`${this.weekRate}%`)
              .fontSize(Theme.type.titleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            Text('完成率')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding(20)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)

        Column({ space: 12 }) {
          Text('分类统计')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          ForEach(CategorySuggest.categories(), (title: string) => {
            this.CatRow(title)
          }, (title: string) => title)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)

        Column({ space: 8 }) {
          Text('本周回顾')
            .fontSize(Theme.type.subtitleS)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.weekDone > 0 ? `本周完成了 ${this.weekDone} 件家庭事项` : '这周还没有完成记录')
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text(this.review)
            .fontSize(Theme.type.bodyS)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s5, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
  }

  @Builder
  CatRow(title: string) {
    Row({ space: 10 }) {
      Image(TaskMedia.cover(CategorySuggest.coverKey(title)))
        .width(36)
        .height(36)
        .borderRadius(10)
        .objectFit(ImageFit.Cover)
      Text(title)
        .fontSize(Theme.type.body)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .layoutWeight(1)
      Text(`${this.share(title)}%`)
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
    }
    .width('100%')
    .onClick(() => this.openCat(title))
  }

  private openCat(title: string): void {
    for (const c of this.cats) {
      if (c.title === title) {
        this.onOpenCategory(c)
        return
      }
    }
    const fallback = new FamilyCategory()
    fallback.title = title
    fallback.coverKey = CategorySuggest.coverKey(title)
    fallback.summary = title
    fallback.body = '把这一类家庭事项记下来，完成时轻轻勾选。'
    this.onOpenCategory(fallback)
  }
}
