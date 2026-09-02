import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { ExperienceEntry } from '../../models/LifeModels'
import { LifeStorePhase3 } from '../../services/LifeStorePhase3'
import { AchievementService } from '../../services/AchievementService'
import { ExperienceCard } from './ExperienceCard'

@Component
export struct ExperienceLibrarySheet {
  onClose: () => void = () => {}
  onChanged: () => void = () => {}
  @State entries: ExperienceEntry[] = []
  @State showEditor: boolean = false
  @State editEntry: ExperienceEntry = new ExperienceEntry()
  @State toastText: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.entries = await LifeStorePhase3.loadExperiences()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2400)
  }

  private openNew(): void {
    this.editEntry = ExperienceEntry.createNew('')
    this.showEditor = true
  }

  private openEdit(entry: ExperienceEntry): void {
    this.editEntry = entry
    this.showEditor = true
  }

  private async saveEntry(): Promise<void> {
    if (this.editEntry.question.trim().length < 2) {
      this.showToast('问题至少 2 字')
      return
    }
    await LifeStorePhase3.saveExperience(this.editEntry)
    this.showEditor = false
    await AchievementService.checkAndUnlock()
    this.onChanged()
    await this.reload()
    this.showToast('已保存')
  }

  private async deleteEntry(id: string): Promise<void> {
    await LifeStorePhase3.deleteExperience(id)
    this.onChanged()
    await this.reload()
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text('经验库')
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().textPrimary)
            .layoutWeight(1)
          Text('关闭')
            .fontColor(Theme.colors().brandPrimary)
            .onClick((): void => { this.onClose() })
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })

        AppButton({ label: '记录新经验', variant: 'primary', onTap: (): void => { this.openNew() } })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.entries.length === 0) {
              AppEmpty({
                title: '经验库还是空的',
                description: '用问-法-果-记结构沉淀你的实践心得',
                actionLabel: '',
                onAction: (): void => {}
              })
            } else {
              ForEach(this.entries, (e: ExperienceEntry) => {
                ExperienceCard({
                  entry: e,
                  onTap: (): void => { this.openEdit(e) },
                  onDelete: (): void => { void this.deleteEntry(e.id) }
                })
              }, (e: ExperienceEntry) => e.id)
            }
          }
          .padding(Theme.space.pageX)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Theme.colors().surfacePage)

      if (this.showEditor) {
        this.EditorOverlay()
      }
      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().brandOnPrimary)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().brandPrimary)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s2 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  EditorOverlay() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.showEditor = false })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          Text('编辑经验')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(Theme.colors().textPrimary)
          TextInput({ text: this.editEntry.question, placeholder: '问题（问）' })
            .onChange((v: string): void => { this.editEntry.question = v })
          TextInput({ text: this.editEntry.method, placeholder: '方法（法）' })
            .onChange((v: string): void => { this.editEntry.method = v })
          TextInput({ text: this.editEntry.result, placeholder: '结果（果）' })
            .onChange((v: string): void => { this.editEntry.result = v })
          TextArea({ text: this.editEntry.note, placeholder: '备注（记）' })
            .height(80)
            .onChange((v: string): void => { this.editEntry.note = v })
          Row({ space: Theme.space.s3 }) {
            AppButton({ label: '取消', variant: 'secondary', onTap: (): void => { this.showEditor = false } })
              .layoutWeight(1)
            AppButton({ label: '保存', variant: 'primary', onTap: (): void => { void this.saveEntry() } })
              .layoutWeight(1)
          }
          .width('100%')
        }
        .padding(Theme.space.s6)
      }
      .width('92%')
      .height('75%')
      .backgroundColor(Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
    }
    .width('100%')
    .height('100%')
    .zIndex(40)
  }
}
