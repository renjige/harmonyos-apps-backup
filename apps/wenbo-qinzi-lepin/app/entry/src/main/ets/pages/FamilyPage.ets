import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { JigsawItem } from '../models/JigsawModels'
import { JigsawBizService } from '../services/JigsawBizService'
import { JigsawMedia } from '../services/JigsawMedia'
import { JigsawNav } from '../services/JigsawNav'
import { JigsawListCard } from '../components/jigsaw/JigsawListCard'

@Component
export struct FamilyPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State picks: JigsawItem[] = []

  aboutToAppear(): void {
    void this.reload()
  }

  async reload(): Promise<void> {
    const all = await JigsawBizService.loadJigsaws()
    const out: JigsawItem[] = []
    let i = 0
    for (const it of all) {
      if (i < 6) {
        out.push(it)
        i++
      }
    }
    this.picks = out
  }

  private startTogether(id: string): void {
    AppStorage.setOrCreate('jigCollab', true)
    JigsawNav.openDetail(id, true)
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          Image(JigsawMedia.cover('hero_collab'))
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
          Column()
            .width('100%')
            .height(180)
            .linearGradient({
              angle: 180,
              colors: [['rgba(42,36,28,0.05)', 0], ['rgba(42,36,28,0.78)', 1]]
            })
          Column({ space: 6 }) {
            Text('亲子时光')
              .fontSize(13)
              .fontColor('#FFFFFF')
            Text('邀请家长一起拼')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
            Text('橙色是孩子，蓝色是家长。同一部手机，轮流点一块。')
              .fontSize(14)
              .fontColor('#FFFFFF')
          }
          .padding(16)
        }
        .width('100%')
        .borderRadius(20)
        .clip(true)

        Column({ space: 8 }) {
          Text('智慧提示')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Text('游戏里点「智慧提示」，会高亮下一块的家。它不会替你拖，也不做评分。')
            .fontSize(14)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
            .lineHeight(22)
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(20)

        Text('选一幅，一起开始')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .width('100%')

        ForEach(this.picks, (it: JigsawItem) => {
          JigsawListCard({
            item: it,
            onOpen: (id: string) => { this.startTogether(id) }
          })
        }, (it: JigsawItem) => it.id)

        if (this.picks.length === 0) {
          AppButton({
            label: '重新加载图库',
            variant: 'secondary',
            onTap: (): void => { void this.reload() }
          })
        }
      }
      .padding({
        left: Theme.space.pageX,
        right: Theme.space.pageX,
        top: Theme.space.s5,
        bottom: Theme.space.s10
      })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}
