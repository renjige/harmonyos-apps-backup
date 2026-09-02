import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ThemeBook, PlanItem } from '../../models/TuceModels'
import { MoveLibrary } from '../../services/MoveLibrary'
import { TuceStore } from '../../services/TuceStore'
import { TuceNav } from '../../services/TuceNav'
import { TuceMedia } from '../../services/TuceMedia'
import { MoveListCard } from '../tuce/MoveListCard'

@Component
export struct ThemeBookPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop bookId: string = ''
  @State book: ThemeBook = new ThemeBook()
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const list = await TuceStore.themes()
    for (const it of list) {
      if (it.id === this.bookId) {
        this.book = it
      }
    }
  }

  private async asPlan(): Promise<void> {
    const plan = new PlanItem()
    plan.id = TuceStore.newId('plan')
    plan.name = this.book.name
    plan.moveIds = this.book.moveIds
    plan.reps = '10|10|10|10'
    plan.minutes = 20
    plan.restSec = 30
    plan.note = '由主题册生成'
    plan.createdAt = Date.now()
    await TuceStore.savePlan(plan)
    TuceNav.bump()
    TuceNav.open('plan', plan.id)
  }

  private async remove(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await TuceStore.deleteTheme(this.bookId)
    TuceNav.bump()
    TuceNav.close()
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(TuceMedia.cover('core'))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius(Theme.radius.lg)
          Text(this.book.name)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .width('100%')
            .padding(Theme.space.s4)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.75)', 1]]
            })
        }
        .width('100%')
        .height(160)

        ForEach(MoveLibrary.splitIds(this.book.moveIds), (moveId: string) => {
          MoveListCard({
            moveId: moveId,
            name: MoveLibrary.find(moveId)?.name ?? moveId,
            meta: MoveLibrary.find(moveId)?.category ?? '',
            coverKey: MoveLibrary.find(moveId)?.coverKey ?? 'warmup'
          })
        }, (moveId: string) => moveId)

        AppButton({
          label: '编成训练方案',
          variant: 'primary',
          onTap: (): void => { void this.asPlan() }
        })
        AppButton({
          label: '编辑主题册',
          variant: 'secondary',
          onTap: (): void => { TuceNav.open('themeedit', this.bookId) }
        })
        AppButton({
          label: this.confirmDelete ? '确认删除主题册' : '删除主题册',
          variant: 'ghost',
          onTap: (): void => { void this.remove() }
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
    }
    .width('100%')
    .height('100%')
  }
}
