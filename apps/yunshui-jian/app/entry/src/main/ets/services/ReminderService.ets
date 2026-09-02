import { common } from '@kit.AbilityKit'
import { YunTodoItem } from '../models/YunModels'

export class ReminderService {
  static lastError: string = ''

  static async scheduleTodo(todo: YunTodoItem, ctx: common.UIAbilityContext): Promise<boolean> {
    return false
  }

  static async cancelTodo(id: number): Promise<void> {
  }
}
