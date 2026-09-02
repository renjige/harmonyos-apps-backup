import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { RecipeItem, ShoppingWriteBody, NoteWriteBody, IngredientLine } from '../../models/KitchenLabModels'
import { KitchenLabMedia } from '../../services/KitchenLabMedia'
import { KitchenLabDetailNav } from '../../services/KitchenLabDetailNav'
import { KitchenLabBizService } from '../../services/KitchenLabBizService'
import { RecipeFavoriteService } from '../../services/RecipeFavoriteService'
import { AuthService } from '../../services/AuthService'
import { DetailShell } from './DetailShell'

@Component
export struct RecipeDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: RecipeItem = new RecipeItem()
  @StorageLink('favoriteTick') favoriteTick: number = 0
  @State fav: boolean = false
  @State showNoteForm: boolean = false
  @State noteTitle: string = ''
  @State noteBody: string = ''
  @State noteMods: string = ''
  @State saving: boolean = false
  onRequireAuth: () => void = () => {}
  onToast: (message: string) => void = (_m: string) => {}

  aboutToAppear(): void {
    this.fav = RecipeFavoriteService.isFavorite(this.item.id)
    this.noteTitle = `${this.item.title} 实验记录`
  }

  private metaLine(): string {
    const parts: string[] = []
    if (this.item.cuisine.length > 0) {
      parts.push(this.item.cuisine)
    }
    if (this.item.difficulty.length > 0) {
      parts.push(this.item.difficulty)
    }
    if (this.item.cookingTime.length > 0) {
      parts.push(this.item.cookingTime)
    }
    if (this.item.servings.length > 0) {
      parts.push(this.item.servings)
    }
    return parts.join(' · ')
  }

  private async toggleFavorite(): Promise<void> {
    if (!AuthService.requireAuth('favorite_recipe')) {
      this.onRequireAuth()
      return
    }
    this.fav = await RecipeFavoriteService.toggle(this.item.id)
    this.onToast(this.fav ? '已收藏菜谱' : '已取消收藏')
  }

  private async addToShopping(): Promise<void> {
    if (!AuthService.requireAuth('sync_shopping')) {
      this.onRequireAuth()
      return
    }
    let count = 0
    for (let ing of this.item.ingredients) {
      const body = new ShoppingWriteBody()
      body.title = ing.name
      body.qty = ing.amount
      body.unit = ''
      body.isChecked = false
      const row = await KitchenLabBizService.createShopping(body)
      if (row !== undefined) {
        count += 1
      }
    }
    if (count > 0) {
      this.onToast(`已加入采购清单 ${count} 项`)
      KitchenLabDetailNav.bump()
    } else {
      this.onToast('加入采购失败，请稍后重试')
    }
  }

  private openNoteForm(): void {
    if (!AuthService.requireAuth('sync_notes')) {
      this.onRequireAuth()
      return
    }
    this.showNoteForm = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private closeNoteForm(): void {
    this.showNoteForm = false
  }

  private async submitNote(): Promise<void> {
    if (this.saving) {
      return
    }
    this.saving = true
    const body = new NoteWriteBody()
    body.title = this.noteTitle.trim().length > 0 ? this.noteTitle.trim() : '烹饪实验'
    body.body = this.noteBody
    body.summary = this.noteBody.length > 60 ? this.noteBody.substring(0, 60) : this.noteBody
    body.modifications = this.noteMods
    body.recipeId = this.item.id
    const row = await KitchenLabBizService.createNote(body)
    this.saving = false
    if (row !== undefined) {
      this.showNoteForm = false
      this.onToast('实验笔记已保存')
      KitchenLabDetailNav.bump()
      return
    }
    this.onToast('保存失败，请稍后重试')
  }

  build() {
    Stack() {
      DetailShell({
        title: '菜谱详情',
        onBack: () => KitchenLabDetailNav.close()
      }) {
        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              Image(KitchenLabMedia.cover(this.item.coverKey))
                .width('100%')
                .height(220)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(220)
                .linearGradient({
                  angle: 180,
                  colors: [[0x00000000, 0.15], [0xE62D3436, 1.0]]
                })
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .padding({
                  left: Theme.space.pageX,
                  right: Theme.space.pageX,
                  bottom: Theme.space.s4
                })
            }
            .width('100%')
            .height(220)
            .clip(true)

            Text(this.metaLine())
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')

            AppCard({ title: '简介' }) {
              Text(this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }

            Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')

            if (this.item.ingredients.length > 0) {
              AppCard({ title: '食材' }) {
                Column({ space: Theme.space.s2 }) {
                  ForEach(this.item.ingredients, (ing: IngredientLine) => {
                    Row() {
                      Text(ing.name)
                        .fontSize(Theme.type.body)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .layoutWeight(1)
                      Text(ing.amount)
                        .fontSize(Theme.type.caption)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                    }
                    .width('100%')
                  }, (ing: IngredientLine) => ing.name)
                }
              }
            }

            if (this.item.steps.length > 0) {
              AppCard({ title: '步骤' }) {
                Column({ space: Theme.space.s3 }) {
                  ForEach(this.item.steps, (step: string, idx: number) => {
                    Row({ space: Theme.space.s3 }) {
                      Text(`${idx + 1}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().brandOnPrimary)
                        .textAlign(TextAlign.Center)
                        .width(24)
                        .height(24)
                        .backgroundColor(Theme.colors().brandPrimary)
                        .borderRadius(Theme.radius.pill)
                      Text(step)
                        .fontSize(Theme.type.body)
                        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Top)
                  }, (step: string, idx: number) => `${idx}_${step}`)
                }
              }
            }

            Column({ space: Theme.space.s3 }) {
              AppButton({
                label: this.fav ? '已收藏' : '收藏菜谱',
                variant: 'secondary',
                onTap: (): void => { void this.toggleFavorite() }
              })
              AppButton({
                label: '加入采购清单',
                onTap: (): void => { void this.addToShopping() }
              })
              AppButton({
                label: '写实验笔记',
                variant: 'secondary',
                onTap: (): void => this.openNoteForm()
              })
            }
            .width('100%')
            .padding({ bottom: Theme.space.s10 })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s4
          })
          .width('100%')
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }

      if (this.showNoteForm) {
        Column({ space: Theme.space.s4 }) {
          Text('写实验笔记')
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          TextInput({ text: this.noteTitle, placeholder: '笔记标题' })
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.noteTitle = v })
          TextInput({ text: this.noteBody, placeholder: '记录火候、调味与心得…' })
            .height(120)
            .padding({ left: 12, right: 12, top: 12, bottom: 12 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.noteBody = v })
          TextInput({ text: this.noteMods, placeholder: '配方调整（选填）' })
            .height(48)
            .padding({ left: 12, right: 12 })
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.noteMods = v })
          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => this.closeNoteForm()
            })
            .layoutWeight(1)
            AppButton({
              label: this.saving ? '保存中…' : '保存笔记',
              disabled: this.saving,
              onTap: (): void => { void this.submitNote() }
            })
            .layoutWeight(1)
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .padding(Theme.space.pageX)
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
