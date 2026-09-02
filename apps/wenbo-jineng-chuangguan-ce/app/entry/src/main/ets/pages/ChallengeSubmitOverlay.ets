import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { StarIndex, SkillLevel, BadgeRule } from '../models/SkillModels'
import { SkillBizService } from '../services/SkillBizService'
import { SkillNav } from '../services/SkillNav'
import { ProgressStore } from '../services/ProgressStore'

@Component
export struct ChallengeSubmitOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State level: SkillLevel = new SkillLevel()
  @State rating: number = 3
  @State note: string = ''
  @State toast: string = ''
  @State submitting: boolean = false
  @State stars: StarIndex[] = StarIndex.five()

  aboutToAppear(): void {
    void this.load()
  }

  async load(): Promise<void> {
    const id = SkillNav.submitLevelId()
    const found = await SkillBizService.loadLevel(id)
    if (found !== undefined) {
      this.level = found
    }
  }

  private showToast(msg: string): void {
    this.toast = msg
    setTimeout(() => { this.toast = '' }, 2500)
  }

  private async submit(): Promise<void> {
    if (this.submitting || this.level.id.length === 0) {
      return
    }
    this.submitting = true
    const cat = this.level.category.length > 0 ? this.level.category : this.level.categoryId
    await ProgressStore.completeLevel(
      this.level.id,
      cat,
      this.level.growthValue > 0 ? this.level.growthValue : this.level.xp,
      this.rating
    )
    const badges = await SkillBizService.loadBadges()
    const allLevels = await SkillBizService.loadAllLevels()
    const ids: string[] = []
    for (const lv of allLevels) {
      ids.push(lv.id)
    }
    const rules: BadgeRule[] = []
    for (const b of badges) {
      const row = new BadgeRule()
      row.id = b.id
      row.rule = b.rule
      rules.push(row)
    }
    await ProgressStore.syncBadges(ids, rules)
    this.showToast('提交成功，成长值已更新')
    setTimeout(() => {
      SkillNav.close()
      this.submitting = false
    }, 900)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('取消')
            .fontSize(15)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
            .onClick(() => SkillNav.close())
          Blank()
          Text('提交闯关心得')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Blank().width(40)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 8 })

        Scroll() {
          Column({ space: 16 }) {
            Text(this.level.title)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')

            Text('自评完成度（1-5 星）')
              .fontSize(14)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            Row({ space: 12 }) {
              ForEach(this.stars, (s: StarIndex) => {
                Text(s.n <= this.rating ? '★' : '☆')
                  .fontSize(28)
                  .fontColor(s.n <= this.rating ?
                    Theme.colors().brandAccent : Theme.colors().textSecondary)
                  .onClick(() => { this.rating = s.n })
              }, (s: StarIndex) => `star-${s.n}`)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)

            Text('心得备注（选填）')
              .fontSize(14)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            TextArea({ text: this.note, placeholder: '记录你的实践要点与反思…' })
              .height(120)
              .fontSize(15)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.sm)
              .onChange((v: string) => { this.note = v })

            Text(`预计获得 +${this.level.growthValue > 0 ? this.level.growthValue : this.level.xp} 成长值`)
              .fontSize(13)
              .fontColor(Theme.colors().brandAccent)
              .width('100%')

            AppButton({
              label: this.submitting ? '提交中…' : '提交并更新进度',
              onTap: () => { void this.submit() }
            })
          }
          .padding({ left: 20, right: 20, bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      if (this.toast.length > 0) {
        Text(this.toast)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(26,42,74,0.88)')
          .borderRadius(Theme.radius.pill)
          .margin({ top: 56 })
          .zIndex(20)
      }
    }
    .width('100%')
    .height('100%')
  }
}
